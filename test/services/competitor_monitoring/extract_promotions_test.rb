require "test_helper"

class CompetitorMonitoring::ExtractPromotionsTest < ActiveSupport::TestCase
  setup do
    @competitor = Competitor.create!(name: "Acme")
    @source = @competitor.monitoring_sources.create!(
      url: "https://example.com", source_type: :website
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

  test "extracts free spins candidate" do
    snap = snapshot_with("50 000 FREE SPINOV stredajšie akcie")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    assert_equal 1, candidates.size
    assert_equal "bonus", candidates.first.promo_type
    assert_equal 50000.0, candidates.first.discount_value.to_f
    assert_equal "50000 free spins", candidates.first.title
  end

  test "extracts euro bonus amount candidate" do
    snap = snapshot_with("VSTUPNÝ BONUS až 10 000 € k vášmu vkladu!")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    euro = candidates.find { |c| c.discount_value.to_f == 10000.0 }
    assert euro, "expected a 10000€ candidate"
    assert_equal "bonus", euro.promo_type
  end

  test "ignores euro amounts below 100" do
    snap = snapshot_with("Minimálny vklad 5 €")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    assert_equal [], candidates
  end

  test "extracts named bonus candidate" do
    snap = snapshot_with("NARODENINOVÝ BONUS MonacoBet oslavuje s tebou!")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    assert_equal 1, candidates.size
    assert_equal "bonus", candidates.first.promo_type
    assert_equal "narodeninový bonus", candidates.first.title
  end

  test "extracts welcome bonus" do
    snap = snapshot_with("Welcome Bonus up to 500€")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    named = candidates.find { |c| c.title == "welcome bonus" }
    assert named, "expected a welcome bonus candidate"
  end
end
