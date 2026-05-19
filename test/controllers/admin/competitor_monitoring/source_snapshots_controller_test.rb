require "test_helper"

class Admin::CompetitorMonitoring::SourceSnapshotsControllerTest < ActionDispatch::IntegrationTest
  INERTIA_HEADERS = { "X-Inertia" => "true" }.freeze

  setup do
    @competitor = Competitor.create!(name: "Acme")
    @source = @competitor.monitoring_sources.create!(
      name: "Main site", url: "https://acme.com",
      source_type: :website, fetch_strategy: :http,
      extractor_type: :hybrid, check_frequency: :daily
    )
    @snapshot = @source.source_snapshots.create!(
      fetched_at: Time.current, status: :success,
      http_status: 200, content_hash: "abc123",
      visible_text: "Hello world", title: "Acme"
    )
  end

  test "GET index returns snapshots for source" do
    get admin_competitor_monitoring_competitor_monitoring_source_source_snapshots_path(@competitor, @source),
        headers: INERTIA_HEADERS
    assert_response :success
    data = response.parsed_body
    assert_equal "CompetitorMonitoring/SourceSnapshots/Index", data["component"]
    assert_equal @source.id, data["props"]["monitoring_source"]["id"]
    ids = data["props"]["snapshots"].map { |s| s["id"] }
    assert_includes ids, @snapshot.id
  end

  test "GET index includes changed flag for each snapshot" do
    get admin_competitor_monitoring_competitor_monitoring_source_source_snapshots_path(@competitor, @source),
        headers: INERTIA_HEADERS
    data = response.parsed_body
    s = data["props"]["snapshots"].find { |x| x["id"] == @snapshot.id }
    assert s.key?("changed")
  end

  test "GET show returns snapshot" do
    get admin_competitor_monitoring_competitor_monitoring_source_source_snapshot_path(@competitor, @source, @snapshot),
        headers: INERTIA_HEADERS
    assert_response :success
    data = response.parsed_body
    assert_equal "CompetitorMonitoring/SourceSnapshots/Show", data["component"]
    assert_equal @snapshot.id, data["props"]["snapshot"]["id"]
    assert_equal "Hello world", data["props"]["snapshot"]["visible_text"]
  end

  test "GET show does not include raw_html" do
    get admin_competitor_monitoring_competitor_monitoring_source_source_snapshot_path(@competitor, @source, @snapshot),
        headers: INERTIA_HEADERS
    data = response.parsed_body
    assert_not data["props"]["snapshot"].key?("raw_html")
  end
end
