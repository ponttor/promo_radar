require "test_helper"

class Admin::CompetitorMonitoring::InstagramPostsControllerTest < ActionDispatch::IntegrationTest
  INERTIA_HEADERS = { "X-Inertia" => "true" }.freeze

  setup do
    @competitor = Competitor.create!(name: "Acme")
    @source = @competitor.monitoring_sources.create!(
      name: "Acme IG", url: "https://www.instagram.com/acme/",
      source_type: :instagram, fetch_strategy: :browser,
      extractor_type: :hybrid, check_frequency: :daily
    )
    @post = @source.instagram_posts.create!(
      instagram_id: "post001",
      posted_at:    1.day.ago,
      post_type:    "photo",
      caption:      "Big promotion! #promo",
      hashtags:     [ "promo" ],
      likes_count:  100,
      comments_count: 5,
      permalink:    "https://www.instagram.com/p/post001/",
      fetched_at:   Time.current
    )
    @credential = InstagramCredential.create!(username: "bot", session_json: "{}", active: true)
  end

  test "GET index returns posts for source" do
    get admin_competitor_monitoring_competitor_monitoring_source_instagram_posts_path(@competitor, @source),
        headers: INERTIA_HEADERS
    assert_response :success
    data = response.parsed_body
    assert_equal "CompetitorMonitoring/InstagramPosts/Index", data["component"]
    ids = data["props"]["posts"].map { |p| p["id"] }
    assert_includes ids, @post.id
  end

  test "GET index includes monitoring_source and competitor in props" do
    get admin_competitor_monitoring_competitor_monitoring_source_instagram_posts_path(@competitor, @source),
        headers: INERTIA_HEADERS
    data = response.parsed_body
    assert_equal @source.id, data["props"]["monitoring_source"]["id"]
    assert_equal @competitor.id, data["props"]["competitor"]["id"]
  end

  test "GET index includes credential_active true when credential is active" do
    get admin_competitor_monitoring_competitor_monitoring_source_instagram_posts_path(@competitor, @source),
        headers: INERTIA_HEADERS
    data = response.parsed_body
    assert_equal true, data["props"]["credential_active"]
  end

  test "GET index includes credential_active false when no active credential" do
    @credential.update!(active: false)
    get admin_competitor_monitoring_competitor_monitoring_source_instagram_posts_path(@competitor, @source),
        headers: INERTIA_HEADERS
    data = response.parsed_body
    assert_equal false, data["props"]["credential_active"]
  end

  test "GET index truncates caption to 100 chars in list" do
    long_caption = "A" * 200
    @source.instagram_posts.create!(
      instagram_id: "post002", posted_at: Time.current,
      post_type: "photo", caption: long_caption, fetched_at: Time.current
    )
    get admin_competitor_monitoring_competitor_monitoring_source_instagram_posts_path(@competitor, @source),
        headers: INERTIA_HEADERS
    data = response.parsed_body
    post_data = data["props"]["posts"].find { |p| p["instagram_id"] == "post002" }
    assert_equal 100, post_data["caption"].length
  end
end
