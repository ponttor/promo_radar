require "test_helper"

class PromotionTest < ActiveSupport::TestCase
  setup do
    @competitor = Competitor.create!(name: "Acme")
  end

  test "status enum has active, expired, unknown" do
    %w[active expired unknown].each do |s|
      assert_includes Promotion.statuses.keys, s
    end
  end

  test "Promotion.active scope returns only active promotions" do
    active = Promotion.create!(competitor: @competitor, status: :active, first_seen_at: Time.current, last_seen_at: Time.current)
    Promotion.create!(competitor: @competitor, status: :expired, first_seen_at: Time.current, last_seen_at: Time.current)
    assert_includes Promotion.active, active
    assert_equal 1, Promotion.active.count
  end

  test "has_many promotion_events" do
    p = Promotion.create!(competitor: @competitor, status: :active, first_seen_at: Time.current, last_seen_at: Time.current)
    assert_respond_to p, :promotion_events
  end
end
