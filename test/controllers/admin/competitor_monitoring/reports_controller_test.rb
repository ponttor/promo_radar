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
end
