module Admin
  module CompetitorMonitoring
    class PromotionsController < ApplicationController
      def index
        promotions = Promotion
          .includes(:competitor, :current_version)
          .order(last_seen_at: :desc)
          .limit(100)

        promotions = promotions.where(competitor_id: params[:competitor_id]) if params[:competitor_id].present?
        promotions = promotions.where(status: params[:status])               if params[:status].present?
        promotions = promotions.where(promo_type: params[:promo_type])       if params[:promo_type].present?

        render inertia: "CompetitorMonitoring/Promotions/Index",
               props: {
                 promotions:   promotions.map { |p| serialize_promotion(p) },
                 competitors:  ::Competitor.active.order(:name).as_json(only: %i[id name]),
                 enum_options: {
                   statuses:    Promotion.statuses.keys,
                   promo_types: Promotion.promo_types.keys
                 },
                 filters: {
                   competitor_id: params[:competitor_id],
                   status:        params[:status],
                   promo_type:    params[:promo_type]
                 }
               }
      end

      def show
        promotion = Promotion
          .includes(:competitor, :promotion_versions, :promotion_events)
          .find(params[:id])

        render inertia: "CompetitorMonitoring/Promotions/Show",
               props: {
                 promotion: promotion.as_json(include: :competitor),
                 versions:  promotion.promotion_versions.order(created_at: :desc).as_json,
                 events:    promotion.promotion_events.order(created_at: :asc).as_json
               }
      end

      private

      def serialize_promotion(p)
        p.as_json(include: :competitor).merge(
          "current_discount_value" => p.current_version&.discount_value,
          "current_promo_code"     => p.current_version&.promo_code
        )
      end
    end
  end
end
