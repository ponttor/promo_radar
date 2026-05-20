require "test_helper"

class Admin::CompetitorMonitoring::ReportsControllerTest < ActionDispatch::IntegrationTest
  INERTIA_HEADERS = { "X-Inertia" => "true" }.freeze

  setup do
    @report = Report.create!(
      report_type: :daily,
      generated_at: Time.current,
      summary_markdown: "# Test\n## Acme\n- 🆕 Nová akcia: **Bonus**",
      summary_html: "<h1>Test</h1><h2>Acme</h2><ul><li>Nová akcia: <strong>Bonus</strong></li></ul>",
      scope_json: {}
    )
  end

  test "GET index returns reports list" do
    get admin_competitor_monitoring_reports_path, headers: INERTIA_HEADERS
    assert_response :success
    data = response.parsed_body
    assert_equal "CompetitorMonitoring/Reports/Index", data["component"]
    assert_includes data["props"]["reports"].map { |r| r["id"] }, @report.id
  end

  test "GET show returns report with items" do
    get admin_competitor_monitoring_report_path(@report), headers: INERTIA_HEADERS
    assert_response :success
    data = response.parsed_body
    assert_equal "CompetitorMonitoring/Reports/Show", data["component"]
    assert_equal @report.id, data["props"]["report"]["id"]
    assert data["props"]["report"]["summary_html"].present?
  end

  test "POST create generates a manual report and redirects to it" do
    assert_difference "Report.count", 1 do
      post admin_competitor_monitoring_reports_path,
        params: { from: 2.days.ago.iso8601, to: Time.current.iso8601 },
        headers: INERTIA_HEADERS
    end
    assert_redirected_to admin_competitor_monitoring_report_path(Report.last)
  end

  test "POST regenerate_summary redirects to show when no events" do
    post regenerate_summary_admin_competitor_monitoring_report_path(@report),
      headers: INERTIA_HEADERS
    assert_redirected_to admin_competitor_monitoring_report_path(@report)
  end

  test "POST regenerate_summary updates scope_json with ai_summary when agent succeeds" do
    competitor = Competitor.create!(name: "Acme")
    promotion = Promotion.create!(
      competitor: competitor, canonical_title: "Welcome Bonus",
      promo_type: "bonus", status: :active,
      first_seen_at: 2.days.ago, last_seen_at: Time.current
    )
    event = PromotionEvent.create!(
      promotion: promotion, event_type: :created
    )
    ReportItem.create!(report: @report, promotion_event: event, sort_order: 0)

    mock_result = Struct.new(:output, :model, :provider, :usage).new(
      "Strong welcome bonus detected.", "claude-haiku", :openrouter, { total_tokens: 10 }
    )
    agent = CompetitorMonitoring::ReportSummaryAgent
    original = agent.method(:call)
    agent.define_singleton_method(:call) { |**| mock_result }

    begin
      post regenerate_summary_admin_competitor_monitoring_report_path(@report),
        headers: INERTIA_HEADERS
      assert_redirected_to admin_competitor_monitoring_report_path(@report)
      assert_equal "Strong welcome bonus detected.", @report.reload.scope_json["ai_summary"]
      assert @report.summary_markdown.start_with?("## AI Summary")
    ensure
      agent.define_singleton_method(:call, &original)
    end
  end

  test "POST regenerate_summary redirects with alert when agent fails" do
    competitor = Competitor.create!(name: "Acme")
    promotion = Promotion.create!(
      competitor: competitor, canonical_title: "Welcome Bonus",
      promo_type: "bonus", status: :active,
      first_seen_at: 2.days.ago, last_seen_at: Time.current
    )
    event = PromotionEvent.create!(promotion: promotion, event_type: :created)
    ReportItem.create!(report: @report, promotion_event: event, sort_order: 0)

    agent = CompetitorMonitoring::ReportSummaryAgent
    original = agent.method(:call)
    agent.define_singleton_method(:call) do |**|
      raise ActiveHarness::Errors::AllModelsFailed, "all models failed"
    end

    begin
      post regenerate_summary_admin_competitor_monitoring_report_path(@report),
        headers: INERTIA_HEADERS
      assert_redirected_to admin_competitor_monitoring_report_path(@report)
      assert_nil @report.reload.scope_json["ai_summary"]
    ensure
      agent.define_singleton_method(:call, &original)
    end
  end
end
