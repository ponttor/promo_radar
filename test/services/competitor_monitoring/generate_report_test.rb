require "test_helper"

class CompetitorMonitoring::GenerateReportTest < ActiveSupport::TestCase
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
end
