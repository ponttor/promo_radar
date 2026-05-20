require "test_helper"

class CompetitorMonitoring::GenerateReportTest < ActiveSupport::TestCase
  # Prevent real AI calls in all tests — stub to raise AllModelsFailed by default
  setup do
    @_original_summary_call = CompetitorMonitoring::ReportSummaryAgent.method(:call)
    CompetitorMonitoring::ReportSummaryAgent.define_singleton_method(:call) do |**|
      raise ActiveHarness::Errors::AllModelsFailed, "stubbed in test setup"
    end
  end

  teardown do
    original = @_original_summary_call
    CompetitorMonitoring::ReportSummaryAgent.define_singleton_method(:call, &original)
  end

  setup do
    @competitor = Competitor.create!(name: "Rival Casino")
    @promotion = Promotion.create!(
      competitor: @competitor,
      canonical_title: "100% uvítací bonus",
      promo_type: "bonus",
      status: :active,
      first_seen_at: 2.days.ago,
      last_seen_at: Time.current
    )
  end

  def make_event(event_type:, details_json: {}, created_at: Time.current)
    PromotionEvent.create!(
      promotion: @promotion,
      event_type: event_type,
      details_json: details_json,
      created_at: created_at
    )
  end

  test "returns a Report record" do
    make_event(event_type: :created)
    result = CompetitorMonitoring::GenerateReport.call(
      report_type: :daily,
      date_range: 1.day.ago..Time.current
    )
    assert_instance_of Report, result
    assert result.persisted?
  end

  test "summary_markdown includes competitor name" do
    make_event(event_type: :created)
    report = CompetitorMonitoring::GenerateReport.call(
      report_type: :daily,
      date_range: 1.day.ago..Time.current
    )
    assert_includes report.summary_markdown, "Rival Casino"
  end

  test "summary_markdown includes promotion title" do
    make_event(event_type: :created)
    report = CompetitorMonitoring::GenerateReport.call(
      report_type: :daily,
      date_range: 1.day.ago..Time.current
    )
    assert_includes report.summary_markdown, "100% uvítací bonus"
  end

  test "summary_html is not blank" do
    make_event(event_type: :created)
    report = CompetitorMonitoring::GenerateReport.call(
      report_type: :daily,
      date_range: 1.day.ago..Time.current
    )
    assert report.summary_html.present?
    assert_includes report.summary_html, "<h1>"
  end

  test "creates report_items for each event" do
    make_event(event_type: :created)
    make_event(event_type: :ended)
    report = CompetitorMonitoring::GenerateReport.call(
      report_type: :daily,
      date_range: 1.day.ago..Time.current
    )
    assert_equal 2, report.report_items.count
  end

  test "filters by competitor_ids when provided" do
    other = Competitor.create!(name: "Other Casino")
    other_promo = Promotion.create!(
      competitor: other, status: :active,
      first_seen_at: Time.current, last_seen_at: Time.current
    )
    PromotionEvent.create!(
      promotion: other_promo, event_type: :created, created_at: Time.current
    )
    make_event(event_type: :created)

    report = CompetitorMonitoring::GenerateReport.call(
      report_type: :manual,
      date_range: 1.day.ago..Time.current,
      competitor_ids: [ @competitor.id ]
    )
    assert_includes report.summary_markdown, "Rival Casino"
    assert_not_includes report.summary_markdown, "Other Casino"
  end

  test "report_type enum is stored correctly" do
    make_event(event_type: :created)
    report = CompetitorMonitoring::GenerateReport.call(
      report_type: :weekly,
      date_range: 7.days.ago..Time.current
    )
    assert report.weekly?
  end

  test "created event renders new promo line with emoji" do
    make_event(event_type: :created)
    report = CompetitorMonitoring::GenerateReport.call(
      report_type: :daily,
      date_range: 1.day.ago..Time.current
    )
    assert_includes report.summary_markdown, "🆕"
  end

  test "ended event renders ended line with emoji" do
    make_event(event_type: :ended, details_json: { "reason" => "not seen for 3 days" })
    report = CompetitorMonitoring::GenerateReport.call(
      report_type: :daily,
      date_range: 1.day.ago..Time.current
    )
    assert_includes report.summary_markdown, "🔚"
  end

  test "updated event renders changed fields" do
    make_event(
      event_type: :updated,
      details_json: { "discount_value" => { "from" => "50", "to" => "100" } }
    )
    report = CompetitorMonitoring::GenerateReport.call(
      report_type: :daily,
      date_range: 1.day.ago..Time.current
    )
    assert_includes report.summary_markdown, "✏️"
    assert_includes report.summary_markdown, "50 → 100"
  end

  test "returns report with zero items when no events in range" do
    report = CompetitorMonitoring::GenerateReport.call(
      report_type: :daily,
      date_range: 1.day.ago..Time.current
    )
    assert_instance_of Report, report
    assert_equal 0, report.report_items.count
  end

  # --- AI summary tests ---

  def stub_summary_agent(result_or_proc)
    agent = CompetitorMonitoring::ReportSummaryAgent
    original = agent.method(:call)
    if result_or_proc.respond_to?(:call)
      agent.define_singleton_method(:call) { |**| result_or_proc.call }
    else
      agent.define_singleton_method(:call) { |**| result_or_proc }
    end
    yield
  ensure
    agent.define_singleton_method(:call, &original)
  end

  def mock_summary_result(text)
    Struct.new(:output, :model, :provider, :usage).new(
      text, "claude-haiku", :openrouter, { total_tokens: 42 }
    )
  end

  test "AI summary is included in scope_json when agent returns text" do
    make_event(event_type: :created)
    result = mock_summary_result("Competitor launched 100% welcome bonus.")
    stub_summary_agent(result) do
      report = CompetitorMonitoring::GenerateReport.call(
        report_type: :daily,
        date_range: 1.day.ago..Time.current
      )
      assert_equal "Competitor launched 100% welcome bonus.", report.scope_json["ai_summary"]
    end
  end

  test "summary_markdown includes ## AI Summary section when AI present" do
    make_event(event_type: :created)
    result = mock_summary_result("Big discount event detected.")
    stub_summary_agent(result) do
      report = CompetitorMonitoring::GenerateReport.call(
        report_type: :daily,
        date_range: 1.day.ago..Time.current
      )
      assert report.summary_markdown.start_with?("## AI Summary")
      assert_includes report.summary_markdown, "Big discount event detected."
    end
  end

  test "ai_summary_skipped is true in scope_json when events exist but agent fails" do
    make_event(event_type: :created)
    stub_summary_agent(-> { raise ActiveHarness::Errors::AllModelsFailed, "all failed" }) do
      report = CompetitorMonitoring::GenerateReport.call(
        report_type: :daily,
        date_range: 1.day.ago..Time.current
      )
      assert_nil report.scope_json["ai_summary"]
      assert report.scope_json["ai_summary_skipped"]
    end
  end

  test "AI summary is not generated when no events" do
    called = false
    stub_summary_agent(-> { called = true }) do
      report = CompetitorMonitoring::GenerateReport.call(
        report_type: :daily,
        date_range: 1.day.ago..Time.current
      )
      assert_not called
      assert_nil report.scope_json["ai_summary"]
    end
  end

  test "ai_calls_count is 1 when agent is called" do
    make_event(event_type: :created)
    result = mock_summary_result("Summary text")
    stub_summary_agent(result) do
      report = CompetitorMonitoring::GenerateReport.call(
        report_type: :daily,
        date_range: 1.day.ago..Time.current
      )
      assert_equal 1, report.scope_json["ai_calls_count"]
    end
  end

  test "ai_calls_count is 0 when no events" do
    report = CompetitorMonitoring::GenerateReport.call(
      report_type: :daily,
      date_range: 1.day.ago..Time.current
    )
    assert_equal 0, report.scope_json["ai_calls_count"]
  end
end
