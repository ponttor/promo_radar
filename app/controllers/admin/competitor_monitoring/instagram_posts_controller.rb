module Admin
  module CompetitorMonitoring
    class InstagramPostsController < ApplicationController
      before_action :set_competitor
      before_action :set_monitoring_source

      def index
        posts = @monitoring_source.instagram_posts.recent.limit(25)

        posts_json = posts.map do |p|
          p.as_json(only: %i[id instagram_id posted_at post_type likes_count comments_count permalink fetched_at])
           .merge("caption" => p.caption.to_s.truncate(100))
        end

        render inertia: "CompetitorMonitoring/InstagramPosts/Index",
               props: {
                 competitor:        @competitor.as_json,
                 monitoring_source: @monitoring_source.as_json,
                 posts:             posts_json,
                 credential_active: InstagramCredential.active.exists?
               }
      end

      private

      def set_competitor
        @competitor = Competitor.find(params[:competitor_id])
      end

      def set_monitoring_source
        @monitoring_source = @competitor.monitoring_sources.find(params[:monitoring_source_id])
      end
    end
  end
end
