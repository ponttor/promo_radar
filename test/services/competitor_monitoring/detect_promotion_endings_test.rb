require "test_helper"

class CompetitorMonitoring::DetectPromotionEndingsTest < ActiveSupport::TestCase
  setup do
    @competitor = Competitor.create!(name: "Acme")
  end

  def active_promotion(last_seen_at:)
    Promotion.create!(
      competitor: @competitor,
      status: :active,
      first_seen_at: last_seen_at,
      last_seen_at: last_seen_at
    )
  end

  test "marks promotion as expired if not seen for threshold days" do
    promo = active_promotion(last_seen_at: 4.days.ago)

    CompetitorMonitoring::DetectPromotionEndings.call(threshold_days: 3)

    assert_equal "expired", promo.reload.status
    assert_equal 1, promo.promotion_events.ended.count
  end

  test "does not expire promotion seen within threshold" do
    promo = active_promotion(last_seen_at: 1.day.ago)

    CompetitorMonitoring::DetectPromotionEndings.call(threshold_days: 3)

    assert_equal "active", promo.reload.status
    assert_equal 0, promo.promotion_events.count
  end

  test "creates ended event with details" do
    promo = active_promotion(last_seen_at: 5.days.ago)

    CompetitorMonitoring::DetectPromotionEndings.call(threshold_days: 3)

    event = promo.promotion_events.ended.first
    assert_not_nil event
    assert_not_nil event.details_json
  end
end
