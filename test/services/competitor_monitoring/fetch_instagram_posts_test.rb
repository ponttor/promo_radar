require "test_helper"

class CompetitorMonitoring::FetchInstagramPostsTest < ActiveSupport::TestCase
  class MockScraper
    def initialize(posts: [], raise_expired: false)
      @posts = posts
      @raise_expired = raise_expired
    end

    def fetch_posts(url:, session_json:)
      raise CompetitorMonitoring::FetchInstagramPosts::SessionExpiredError if @raise_expired
      @posts
    end
  end

  def setup
    @competitor = Competitor.create!(name: "Acme")
    @source = @competitor.monitoring_sources.create!(
      name: "Acme IG", url: "https://www.instagram.com/acme/",
      source_type: :instagram, fetch_strategy: :browser,
      extractor_type: :hybrid, check_frequency: :daily
    )
    @credential = InstagramCredential.create!(
      username: "monitor_bot", session_json: '{"cookies":[],"origins":[]}', active: true
    )
  end

  def sample_post_data(overrides = {})
    {
      instagram_id:   "post001",
      posted_at:      1.day.ago,
      post_type:      "photo",
      caption:        "Summer sale! #promo #casino",
      likes_count:    120,
      comments_count: 8,
      media_url:      "https://cdn.instagram.com/photo.jpg",
      permalink:      "https://www.instagram.com/p/post001/"
    }.merge(overrides)
  end

  test "creates instagram_posts for new posts" do
    scraper = MockScraper.new(posts: [sample_post_data])
    assert_difference "@source.instagram_posts.count", 1 do
      CompetitorMonitoring::FetchInstagramPosts.call(monitoring_source: @source, scraper: scraper)
    end
  end

  test "extracts hashtags from caption" do
    scraper = MockScraper.new(posts: [sample_post_data(caption: "Big #promo on #slots today!")])
    CompetitorMonitoring::FetchInstagramPosts.call(monitoring_source: @source, scraper: scraper)
    post = @source.instagram_posts.last
    assert_includes post.hashtags, "promo"
    assert_includes post.hashtags, "slots"
  end

  test "skips posts already in DB" do
    @source.instagram_posts.create!(
      instagram_id: "post001", fetched_at: Time.current,
      posted_at: 1.day.ago, post_type: "photo", caption: "old"
    )
    scraper = MockScraper.new(posts: [sample_post_data])
    assert_no_difference "@source.instagram_posts.count" do
      CompetitorMonitoring::FetchInstagramPosts.call(monitoring_source: @source, scraper: scraper)
    end
  end

  test "returns array of created posts" do
    scraper = MockScraper.new(posts: [sample_post_data])
    result = CompetitorMonitoring::FetchInstagramPosts.call(monitoring_source: @source, scraper: scraper)
    assert_equal 1, result.size
    assert_equal "post001", result.first.instagram_id
  end

  test "updates credential last_verified_at on success" do
    scraper = MockScraper.new(posts: [])
    travel_to(Time.current) do
      CompetitorMonitoring::FetchInstagramPosts.call(monitoring_source: @source, scraper: scraper)
      assert_equal Time.current, @credential.reload.last_verified_at
    end
  end

  test "marks credential inactive and re-raises on SessionExpiredError" do
    scraper = MockScraper.new(raise_expired: true)
    assert_raises CompetitorMonitoring::FetchInstagramPosts::SessionExpiredError do
      CompetitorMonitoring::FetchInstagramPosts.call(monitoring_source: @source, scraper: scraper)
    end
    assert_not @credential.reload.active
  end

  test "raises when no active credential" do
    @credential.update!(active: false)
    scraper = MockScraper.new(posts: [])
    assert_raises ActiveRecord::RecordNotFound do
      CompetitorMonitoring::FetchInstagramPosts.call(monitoring_source: @source, scraper: scraper)
    end
  end
end
