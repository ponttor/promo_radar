require "test_helper"

class Admin::CompetitorMonitoring::CompetitorsControllerTest < ActionDispatch::IntegrationTest
  INERTIA_HEADERS = { "X-Inertia" => "true" }.freeze

  setup do
    @competitor = Competitor.create!(name: "TestCo", industry: "Retail")
  end

  test "GET index returns competitors list" do
    get admin_competitor_monitoring_competitors_path, headers: INERTIA_HEADERS
    assert_response :success
    data = response.parsed_body
    assert_equal "CompetitorMonitoring/Competitors/Index", data["component"]
    names = data["props"]["competitors"].map { |c| c["name"] }
    assert_includes names, "TestCo"
  end

  test "GET new renders form component" do
    get new_admin_competitor_monitoring_competitor_path, headers: INERTIA_HEADERS
    assert_response :success
    data = response.parsed_body
    assert_equal "CompetitorMonitoring/Competitors/New", data["component"]
  end

  test "POST create with valid params creates competitor and redirects" do
    assert_difference "Competitor.count", 1 do
      post admin_competitor_monitoring_competitors_path,
        params: { competitor: { name: "New Co", industry: "Finance", country: "RU" } },
        headers: INERTIA_HEADERS
    end
    assert_redirected_to admin_competitor_monitoring_competitors_path
  end

  test "POST create with invalid params renders errors" do
    assert_no_difference "Competitor.count" do
      post admin_competitor_monitoring_competitors_path,
        params: { competitor: { name: "" } },
        headers: INERTIA_HEADERS
    end
    assert_response :unprocessable_entity
    data = response.parsed_body
    assert data["props"]["errors"].present?
  end

  test "GET edit renders form with competitor data" do
    get edit_admin_competitor_monitoring_competitor_path(@competitor), headers: INERTIA_HEADERS
    assert_response :success
    data = response.parsed_body
    assert_equal "CompetitorMonitoring/Competitors/Edit", data["component"]
    assert_equal "TestCo", data["props"]["competitor"]["name"]
  end

  test "PATCH update with valid params updates competitor" do
    patch admin_competitor_monitoring_competitor_path(@competitor),
      params: { competitor: { name: "Updated Co" } },
      headers: INERTIA_HEADERS
    assert_redirected_to admin_competitor_monitoring_competitors_path
    assert_equal "Updated Co", @competitor.reload.name
  end

  test "PATCH update active false deactivates competitor" do
    patch admin_competitor_monitoring_competitor_path(@competitor),
      params: { competitor: { active: false } },
      headers: INERTIA_HEADERS
    assert_not @competitor.reload.active?
  end
end
