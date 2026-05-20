require "test_helper"

class CompetitorMonitoring::NormalizePromotionTest < ActiveSupport::TestCase
  setup do
    @competitor = Competitor.create!(name: "Acme")
    @source = @competitor.monitoring_sources.create!(
      name: "Main", url: "https://example.com",
      source_type: :website, fetch_strategy: :http,
      extractor_type: :hybrid, check_frequency: :daily
    )
    @snapshot = @source.source_snapshots.create!(
      fetched_at: Time.current, status: :success,
      content_hash: "abc", visible_text: "10% off"
    )
  end

  def make_candidate(overrides = {})
    PromotionCandidate.create!({
      source_snapshot: @snapshot,
      competitor: @competitor,
      title: "10% discount",
      promo_type: :discount,
      discount_value: 10.0,
      promo_code: "spring24",
      confidence: 0.7,
      raw_extraction_json: { "extraction_method" => "rule_based" }
    }.merge(overrides))
  end

  test "promo_code is uppercased" do
    candidate = make_candidate(promo_code: "spring24")
    CompetitorMonitoring::NormalizePromotion.call(promotion_candidate: candidate)
    assert_equal "SPRING24", candidate.reload.promo_code
  end

  test "fingerprint is stable with different whitespace in title" do
    c1 = make_candidate(title: "10%  discount ", promo_code: "CODE1")
    c2 = make_candidate(title: "10% discount",   promo_code: "CODE1")
    CompetitorMonitoring::NormalizePromotion.call(promotion_candidate: c1)
    CompetitorMonitoring::NormalizePromotion.call(promotion_candidate: c2)
    assert_equal c1.reload.fingerprint, c2.reload.fingerprint
  end

  test "fingerprint differs when promo_code differs" do
    c1 = make_candidate(title: "10% discount", promo_code: "CODE1")
    c2 = make_candidate(title: "10% discount", promo_code: "CODE2")
    CompetitorMonitoring::NormalizePromotion.call(promotion_candidate: c1)
    CompetitorMonitoring::NormalizePromotion.call(promotion_candidate: c2)
    assert_not_equal c1.reload.fingerprint, c2.reload.fingerprint
  end

  test "fingerprint is set on the candidate record" do
    candidate = make_candidate
    CompetitorMonitoring::NormalizePromotion.call(promotion_candidate: candidate)
    assert_not_nil candidate.reload.fingerprint
    assert_equal 64, candidate.fingerprint.length
  end

  test "discount_value is rounded to 2 decimal places" do
    candidate = make_candidate(discount_value: 10.123456)
    CompetitorMonitoring::NormalizePromotion.call(promotion_candidate: candidate)
    assert_equal 10.12, candidate.reload.discount_value.to_f
  end
end
