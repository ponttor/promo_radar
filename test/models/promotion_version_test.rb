require "test_helper"

class PromotionVersionTest < ActiveSupport::TestCase
  setup do
    @competitor = Competitor.create!(name: "Acme")
    @source = @competitor.monitoring_sources.create!(
      name: "Main", url: "https://example.com",
      source_type: :website, fetch_strategy: :http,
      extractor_type: :hybrid, check_frequency: :daily
    )
    @snapshot = @source.source_snapshots.create!(
      fetched_at: Time.current, status: :success,
      content_hash: "abc", visible_text: "hello"
    )
    @promotion = Promotion.create!(
      competitor: @competitor, status: :active,
      first_seen_at: Time.current, last_seen_at: Time.current
    )
  end

  test "belongs_to promotion and source_snapshot" do
    version = PromotionVersion.create!(
      promotion: @promotion,
      source_snapshot: @snapshot,
      version_hash: "hash123"
    )
    assert_equal @promotion, version.promotion
    assert_equal @snapshot, version.source_snapshot
  end
end
