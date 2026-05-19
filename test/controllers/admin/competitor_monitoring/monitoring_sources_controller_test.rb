require "test_helper"

class Admin::CompetitorMonitoring::MonitoringSourcesControllerTest < ActionDispatch::IntegrationTest
  INERTIA_HEADERS = { "X-Inertia" => "true" }.freeze

  setup do
    @competitor = Competitor.create!(name: "Acme")
    @source = @competitor.monitoring_sources.create!(
      name: "Main site",
      url: "https://acme.com",
      source_type: :website,
      fetch_strategy: :http,
      extractor_type: :hybrid,
      check_frequency: :daily
    )
  end

  test "GET index returns sources for competitor" do
    get admin_competitor_monitoring_competitor_monitoring_sources_path(@competitor),
        headers: INERTIA_HEADERS
    assert_response :success
    data = response.parsed_body
    assert_equal "CompetitorMonitoring/MonitoringSources/Index", data["component"]
    assert_equal @competitor.id, data["props"]["competitor"]["id"]
    names = data["props"]["monitoring_sources"].map { |s| s["name"] }
    assert_includes names, "Main site"
  end

  test "GET new renders form" do
    get new_admin_competitor_monitoring_competitor_monitoring_source_path(@competitor),
        headers: INERTIA_HEADERS
    assert_response :success
    data = response.parsed_body
    assert_equal "CompetitorMonitoring/MonitoringSources/New", data["component"]
    assert data["props"]["enum_options"].present?
  end

  test "POST create with valid params creates source" do
    assert_difference "MonitoringSource.count", 1 do
      post admin_competitor_monitoring_competitor_monitoring_sources_path(@competitor),
        params: {
          monitoring_source: {
            name: "Promos page",
            url: "https://acme.com/promos",
            source_type: "website",
            fetch_strategy: "http",
            extractor_type: "hybrid",
            check_frequency: "daily"
          }
        },
        headers: INERTIA_HEADERS
    end
    assert_redirected_to admin_competitor_monitoring_competitor_monitoring_sources_path(@competitor)
  end

  test "POST create with invalid params renders errors" do
    assert_no_difference "MonitoringSource.count" do
      post admin_competitor_monitoring_competitor_monitoring_sources_path(@competitor),
        params: { monitoring_source: { name: "", url: "" } },
        headers: INERTIA_HEADERS
    end
    assert_response :unprocessable_entity
    data = response.parsed_body
    assert data["props"]["errors"].present?
  end

  test "PATCH update with valid params updates source" do
    patch admin_competitor_monitoring_competitor_monitoring_source_path(@competitor, @source),
      params: { monitoring_source: { name: "Updated site" } },
      headers: INERTIA_HEADERS
    assert_redirected_to admin_competitor_monitoring_competitor_monitoring_sources_path(@competitor)
    assert_equal "Updated site", @source.reload.name
  end
end
