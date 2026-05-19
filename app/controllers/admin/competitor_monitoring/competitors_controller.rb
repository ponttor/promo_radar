module Admin
  module CompetitorMonitoring
    class CompetitorsController < ApplicationController
      before_action :set_competitor, only: [:edit, :update]

      def index
        competitors = Competitor.order(:name).map do |c|
          c.as_json.merge("monitoring_sources_count" => c.monitoring_sources.count)
        end
        render inertia: "CompetitorMonitoring/Competitors/Index",
               props: { competitors: competitors }
      end

      def new
        render inertia: "CompetitorMonitoring/Competitors/New",
               props: { competitor: Competitor.new.as_json, errors: {} }
      end

      def create
        @competitor = Competitor.new(competitor_params)
        if @competitor.save
          redirect_to admin_competitor_monitoring_competitors_path
        else
          render inertia: "CompetitorMonitoring/Competitors/New",
                 props: { competitor: @competitor.as_json, errors: @competitor.errors.messages },
                 status: :unprocessable_entity
        end
      end

      def edit
        render inertia: "CompetitorMonitoring/Competitors/Edit",
               props: { competitor: @competitor.as_json, errors: {} }
      end

      def update
        if @competitor.update(competitor_params)
          redirect_to admin_competitor_monitoring_competitors_path
        else
          render inertia: "CompetitorMonitoring/Competitors/Edit",
                 props: { competitor: @competitor.as_json, errors: @competitor.errors.messages },
                 status: :unprocessable_entity
        end
      end

      private

      def set_competitor
        @competitor = Competitor.find(params[:id])
      end

      def competitor_params
        params.require(:competitor).permit(:name, :industry, :country, :notes, :active)
      end
    end
  end
end
