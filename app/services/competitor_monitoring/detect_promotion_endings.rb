module CompetitorMonitoring
  class DetectPromotionEndings
    def self.call(threshold_days: 3)
      new(threshold_days).call
    end

    def initialize(threshold_days)
      @threshold_days = threshold_days
    end

    def call
      Promotion.active.where("last_seen_at < ?", @threshold_days.days.ago).find_each do |promotion|
        PromotionEvent.create!(
          promotion:    promotion,
          event_type:   :ended,
          details_json: { "reason" => "not seen for #{@threshold_days} days" },
          created_at:   Time.current
        )
        promotion.update!(status: :expired)
      end
    end
  end
end
