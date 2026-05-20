module Admin
  module CompetitorMonitoring
    class CompetitorsController < ApplicationController
      before_action :set_competitor, only: [ :show, :edit, :update, :destroy ]

      def index
        competitors = Competitor.order(:name).map do |c|
          c.as_json.merge("monitoring_sources_count" => c.monitoring_sources.count)
        end
        render inertia: "CompetitorMonitoring/Competitors/Index",
               props: { competitors: competitors }
      end

      def show
        render inertia: "CompetitorMonitoring/Competitors/Show",
               props: { competitor: competitor_json(@competitor) }
      end

      def new
        render inertia: "CompetitorMonitoring/Competitors/New",
               props: { competitor: competitor_json(Competitor.new), errors: {} }
      end

      def create
        @competitor = Competitor.new(competitor_params)
        if @competitor.save
          redirect_to admin_competitor_monitoring_competitors_path
        else
          render inertia: "CompetitorMonitoring/Competitors/New",
                 props: { competitor: competitor_json(@competitor), errors: @competitor.errors.messages },
                 status: :unprocessable_entity
        end
      end

      def edit
        render inertia: "CompetitorMonitoring/Competitors/Edit",
               props: { competitor: competitor_json(@competitor), errors: {} }
      end

      def update
        if @competitor.update(competitor_params)
          redirect_to admin_competitor_monitoring_competitors_path
        else
          render inertia: "CompetitorMonitoring/Competitors/Edit",
                 props: { competitor: competitor_json(@competitor), errors: @competitor.errors.messages },
                 status: :unprocessable_entity
        end
      end

      def destroy
        @competitor.destroy
        redirect_to admin_competitor_monitoring_competitors_path
      end

      private

      def set_competitor
        @competitor = Competitor.find(params[:id])
      end

      def competitor_params
        params.require(:competitor).permit(
          :name, :active,
          monitoring_sources_attributes: [ :id, :url, :source_type, :active, :_destroy ]
        )
      end

      def competitor_json(competitor)
        competitor.as_json.merge(
          "monitoring_sources" => competitor.monitoring_sources.map { |s|
            s.as_json(only: %i[id url source_type active])
          }
        )
      end
    end
  end
end
