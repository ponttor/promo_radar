require "test_helper"

class Admin::CompetitorMonitoring::CompetitorsControllerTest < ActionDispatch::IntegrationTest
  INERTIA_HEADERS = { "X-Inertia" => "true" }.freeze

  setup do
    @competitor = Competitor.create!(name: "TestCo")
  end

  test "GET index returns competitors list" do
    get admin_competitor_monitoring_competitors_path, headers: INERTIA_HEADERS
    assert_response :success
    data = response.parsed_body
    assert_equal "CompetitorMonitoring/Competitors/Index", data["component"]
    assert_includes data["props"]["competitors"].map { |c| c["name"] }, "TestCo"
  end

  test "GET new includes empty monitoring_sources array" do
    get new_admin_competitor_monitoring_competitor_path, headers: INERTIA_HEADERS
    assert_response :success
    data = response.parsed_body
    assert_equal "CompetitorMonitoring/Competitors/New", data["component"]
    assert_equal [], data["props"]["competitor"]["monitoring_sources"]
  end

  test "POST create with valid params creates competitor" do
    assert_difference "Competitor.count", 1 do
      post admin_competitor_monitoring_competitors_path,
        params: { competitor: { name: "New Co", active: true } },
        headers: INERTIA_HEADERS
    end
    assert_redirected_to admin_competitor_monitoring_competitors_path
  end

  test "POST create with nested sources creates competitor and sources" do
    assert_difference [ "Competitor.count", "MonitoringSource.count" ] do
      post admin_competitor_monitoring_competitors_path,
        params: {
          competitor: {
            name: "New Co",
            active: true,
            monitoring_sources_attributes: {
              "0" => { url: "https://newco.com", source_type: "website", active: true }
            }
          }
        },
        headers: INERTIA_HEADERS
    end
    assert_equal "https://newco.com", Competitor.last.monitoring_sources.first.url
  end

  test "POST create with invalid params renders errors" do
    assert_no_difference "Competitor.count" do
      post admin_competitor_monitoring_competitors_path,
        params: { competitor: { name: "" } },
        headers: INERTIA_HEADERS
    end
    assert_response :unprocessable_entity
    assert response.parsed_body["props"]["errors"].present?
  end

  test "GET edit includes monitoring_sources in competitor prop" do
    source = @competitor.monitoring_sources.create!(url: "https://testco.com", source_type: "website")
    get edit_admin_competitor_monitoring_competitor_path(@competitor), headers: INERTIA_HEADERS
    assert_response :success
    data = response.parsed_body
    assert_equal "CompetitorMonitoring/Competitors/Edit", data["component"]
    assert_equal "TestCo", data["props"]["competitor"]["name"]
    assert_includes data["props"]["competitor"]["monitoring_sources"].map { |s| s["url"] },
                    "https://testco.com"
  end

  test "PATCH update renames competitor" do
    patch admin_competitor_monitoring_competitor_path(@competitor),
      params: { competitor: { name: "Updated Co" } },
      headers: INERTIA_HEADERS
    assert_redirected_to admin_competitor_monitoring_competitors_path
    assert_equal "Updated Co", @competitor.reload.name
  end

  test "PATCH update adds source via nested attributes" do
    assert_difference "MonitoringSource.count", 1 do
      patch admin_competitor_monitoring_competitor_path(@competitor),
        params: {
          competitor: {
            monitoring_sources_attributes: {
              "0" => { url: "https://testco.com/promos", source_type: "website", active: true }
            }
          }
        },
        headers: INERTIA_HEADERS
    end
  end

  test "PATCH update destroys source via _destroy" do
    source = @competitor.monitoring_sources.create!(url: "https://testco.com", source_type: "website")
    assert_difference "MonitoringSource.count", -1 do
      patch admin_competitor_monitoring_competitor_path(@competitor),
        params: {
          competitor: {
            monitoring_sources_attributes: { "0" => { id: source.id, _destroy: "1" } }
          }
        },
        headers: INERTIA_HEADERS
    end
  end

  test "DELETE destroy removes competitor and redirects" do
    assert_difference "Competitor.count", -1 do
      delete admin_competitor_monitoring_competitor_path(@competitor)
    end
    assert_redirected_to admin_competitor_monitoring_competitors_path
  end

  test "DELETE destroy cascades to sources" do
    @competitor.monitoring_sources.create!(url: "https://testco.com", source_type: "website")
    assert_difference "MonitoringSource.count", -1 do
      delete admin_competitor_monitoring_competitor_path(@competitor)
    end
  end
end
