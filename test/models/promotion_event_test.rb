require "test_helper"

class PromotionEventTest < ActiveSupport::TestCase
  setup do
    @competitor = Competitor.create!(name: "Acme")
    @promotion = Promotion.create!(
      competitor: @competitor, status: :active,
      first_seen_at: Time.current, last_seen_at: Time.current
    )
  end

  test "belongs_to promotion" do
    event = PromotionEvent.create!(
      promotion: @promotion,
      event_type: :created,
      created_at: Time.current
    )
    assert_equal @promotion, event.promotion
  end

  test "event_type enum has created, updated, ended, reappeared" do
    %w[created updated ended reappeared].each do |t|
      assert_includes PromotionEvent.event_types.keys, t
    end
  end

  test "source_snapshot is optional" do
    event = PromotionEvent.create!(
      promotion: @promotion,
      event_type: :ended,
      created_at: Time.current
    )
    assert_nil event.source_snapshot
  end
end
