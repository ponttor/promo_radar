require "test_helper"

class InstagramPostTest < ActiveSupport::TestCase
  def setup
    @competitor = Competitor.create!(name: "Acme")
    @source = @competitor.monitoring_sources.create!(
      name: "Acme IG", url: "https://www.instagram.com/acme/",
      source_type: :instagram, fetch_strategy: :browser,
      extractor_type: :hybrid, check_frequency: :daily
    )
  end

  def valid_post_attrs(overrides = {})
    {
      instagram_id: "abc123xyz",
      posted_at: 1.day.ago,
      post_type: "photo",
      caption: "Big sale! #promo #casino",
      hashtags: ["promo", "casino"],
      likes_count: 100,
      comments_count: 5,
      media_url: "https://cdn.instagram.com/image.jpg",
      permalink: "https://www.instagram.com/p/abc123xyz/",
      fetched_at: Time.current
    }.merge(overrides)
  end

  test "valid with required attributes" do
    post = @source.instagram_posts.new(valid_post_attrs)
    assert post.valid?
  end

  test "invalid without instagram_id" do
    post = @source.instagram_posts.new(valid_post_attrs(instagram_id: nil))
    assert_not post.valid?
  end

  test "invalid without fetched_at" do
    post = @source.instagram_posts.new(valid_post_attrs(fetched_at: nil))
    assert_not post.valid?
  end

  test "enforces unique instagram_id per monitoring_source" do
    @source.instagram_posts.create!(valid_post_attrs)
    dup = @source.instagram_posts.new(valid_post_attrs)
    assert_not dup.valid?
    assert_includes dup.errors[:instagram_id], "has already been taken"
  end

  test "allows same instagram_id across different sources" do
    other_source = @competitor.monitoring_sources.create!(
      name: "Other IG", url: "https://www.instagram.com/other/",
      source_type: :instagram, fetch_strategy: :browser,
      extractor_type: :hybrid, check_frequency: :daily
    )
    @source.instagram_posts.create!(valid_post_attrs)
    post2 = other_source.instagram_posts.new(valid_post_attrs)
    assert post2.valid?
  end

  test "recent scope orders by posted_at desc" do
    p1 = @source.instagram_posts.create!(valid_post_attrs(posted_at: 2.days.ago, instagram_id: "id1"))
    p2 = @source.instagram_posts.create!(valid_post_attrs(posted_at: 1.hour.ago, instagram_id: "id2"))
    assert_equal [p2, p1], @source.instagram_posts.recent.to_a
  end

  test "belongs_to monitoring_source" do
    post = @source.instagram_posts.create!(valid_post_attrs)
    assert_equal @source, post.monitoring_source
  end
end
