require "test_helper"

class ReportItemTest < ActiveSupport::TestCase
  setup do
    @report = Report.create!(report_type: :daily, generated_at: Time.current, summary_markdown: "x")
    competitor = Competitor.create!(name: "Acme")
    promotion = Promotion.create!(
      competitor: competitor, status: :active,
      first_seen_at: Time.current, last_seen_at: Time.current
    )
    @event = PromotionEvent.create!(
      promotion: promotion, event_type: :created, created_at: Time.current
    )
  end

  test "belongs_to report and promotion_event" do
    item = ReportItem.create!(report: @report, promotion_event: @event, sort_order: 0)
    assert_equal @report, item.report
    assert_equal @event, item.promotion_event
  end

  test "ordered scope returns items by sort_order ascending" do
    ReportItem.create!(report: @report, promotion_event: @event, sort_order: 5)
    ReportItem.create!(report: @report, promotion_event: @event, sort_order: 1)
    orders = ReportItem.ordered.pluck(:sort_order)
    assert_equal orders.sort, orders
  end
end
