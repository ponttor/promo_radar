require "test_helper"

class CompetitorMonitoring::ExtractPromotionsTest < ActiveSupport::TestCase
  setup do
    @competitor = Competitor.create!(name: "Acme")
    @source = @competitor.monitoring_sources.create!(
      name: "Main", url: "https://example.com",
      source_type: :website, fetch_strategy: :http,
      extractor_type: :hybrid, check_frequency: :daily
    )
  end

  def snapshot_with(text)
    @source.source_snapshots.create!(
      fetched_at: Time.current, status: :success,
      content_hash: Digest::SHA256.hexdigest(text), visible_text: text
    )
  end

  test "extracts percent discount candidate" do
    snap = snapshot_with("Скидка 20% off на все товары")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    assert_equal 1, candidates.size
    assert_equal 20.0, candidates.first.discount_value.to_f
    assert_equal "discount", candidates.first.promo_type
    assert_equal 0.7, candidates.first.confidence.to_f
    assert_equal "rule_based", candidates.first.raw_extraction_json["extraction_method"]
  end

  test "extracts promo code when present alongside discount" do
    snap = snapshot_with("Скидка 20% до 31 мая, промокод SPRING24")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    assert_equal 1, candidates.size
    assert_equal 20.0, candidates.first.discount_value.to_f
    assert_equal "SPRING24", candidates.first.promo_code
  end

  test "extracts cashback candidate" do
    snap = snapshot_with("Get 15% cashback on your order")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    assert_equal 1, candidates.size
    assert_equal "cashback", candidates.first.promo_type
    assert_equal 15.0, candidates.first.discount_value.to_f
  end

  test "returns empty array when no promotions found" do
    snap = snapshot_with("Welcome to our store. We sell great products.")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    assert_equal [], candidates
  end

  test "promo code extraction works with code: prefix format" do
    snap = snapshot_with("Save 10% off, use code: SAVE10")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    assert_equal "SAVE10", candidates.first.promo_code
  end
end
