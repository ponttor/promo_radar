require "test_helper"

class CompetitorMonitoring::MatchPromotionTest < ActiveSupport::TestCase
  setup do
    @competitor = Competitor.create!(name: "Acme")
    @source = @competitor.monitoring_sources.create!(
      url: "https://example.com", source_type: :website
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
      promo_code: "SPRING24",
      fingerprint: "fp_abc123",
      confidence: 0.7,
      raw_extraction_json: { "extraction_method" => "rule_based" }
    }.merge(overrides))
  end

  test "creates new Promotion + Version + created event for first-time fingerprint" do
    candidate = make_candidate

    result = CompetitorMonitoring::MatchPromotion.call(promotion_candidate: candidate)

    assert_instance_of Promotion, result[:promotion]
    assert_instance_of PromotionVersion, result[:version]
    assert_instance_of PromotionEvent, result[:event]
    assert_equal "created", result[:event].event_type
    assert_equal "active", result[:promotion].status
    assert_equal candidate.promotion, result[:promotion]
  end

  test "does not create duplicate Promotion on second call with same fingerprint" do
    c1 = make_candidate
    c2 = make_candidate(fingerprint: "fp_abc123")

    CompetitorMonitoring::MatchPromotion.call(promotion_candidate: c1)

    assert_difference "Promotion.count", 0 do
      CompetitorMonitoring::MatchPromotion.call(promotion_candidate: c2)
    end
  end

  test "creates updated event when discount_value changes" do
    c1 = make_candidate(discount_value: 10.0)
    c2 = make_candidate(fingerprint: "fp_abc123", discount_value: 20.0)

    CompetitorMonitoring::MatchPromotion.call(promotion_candidate: c1)
    result = CompetitorMonitoring::MatchPromotion.call(promotion_candidate: c2)

    assert_equal "updated", result[:event].event_type
    assert_equal 2, result[:promotion].promotion_versions.count
  end

  test "no new event when nothing changed on repeat call" do
    c1 = make_candidate
    c2 = make_candidate(fingerprint: "fp_abc123")

    CompetitorMonitoring::MatchPromotion.call(promotion_candidate: c1)
    result = CompetitorMonitoring::MatchPromotion.call(promotion_candidate: c2)

    assert_nil result[:event]
    assert_equal 1, result[:promotion].promotion_versions.count
  end

  test "updates last_seen_at on every match" do
    c1 = make_candidate
    CompetitorMonitoring::MatchPromotion.call(promotion_candidate: c1)

    travel_to 1.day.from_now do
      c2 = make_candidate(fingerprint: "fp_abc123")
      CompetitorMonitoring::MatchPromotion.call(promotion_candidate: c2)

      promotion = Promotion.last
      assert promotion.last_seen_at > 12.hours.ago
    end
  end
end
