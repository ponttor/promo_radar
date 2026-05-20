module Admin
  module CompetitorMonitoring
    class MonitoringSourcesController < ApplicationController
      before_action :set_competitor_and_source

      def fetch
        if @source.instagram?
          ::CompetitorMonitoring::FetchInstagramPosts.call(monitoring_source: @source)
          redirect_to admin_competitor_monitoring_competitor_monitoring_source_instagram_posts_path(
            @competitor, @source
          )
        else
          snapshot = ::CompetitorMonitoring::FetchSource.call(monitoring_source: @source)
          if snapshot&.success?
            candidates = ::CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snapshot)
            candidates.each do |c|
              ::CompetitorMonitoring::NormalizePromotion.call(promotion_candidate: c)
              ::CompetitorMonitoring::MatchPromotion.call(promotion_candidate: c)
            end
          end
          redirect_to admin_competitor_monitoring_promotions_path
        end
      rescue => e
        redirect_to edit_admin_competitor_monitoring_competitor_path(@competitor),
                    alert: e.message.truncate(200)
      end

      private

      def set_competitor_and_source
        @competitor = Competitor.find(params[:competitor_id])
        @source = @competitor.monitoring_sources.find(params[:id])
      end
    end
  end
end
