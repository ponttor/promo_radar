module Admin
  module CompetitorMonitoring
    class MonitoringSourcesController < ApplicationController
      before_action :set_competitor
      before_action :set_source, only: [:edit, :update]

      def index
        render inertia: "CompetitorMonitoring/MonitoringSources/Index",
               props: {
                 competitor: @competitor.as_json,
                 monitoring_sources: @competitor.monitoring_sources.order(:name).as_json
               }
      end

      def new
        render inertia: "CompetitorMonitoring/MonitoringSources/New",
               props: {
                 competitor: @competitor.as_json,
                 monitoring_source: MonitoringSource.new.as_json,
                 errors: {},
                 enum_options: enum_options
               }
      end

      def create
        @source = @competitor.monitoring_sources.new(source_params)
        if @source.save
          redirect_to admin_competitor_monitoring_competitor_monitoring_sources_path(@competitor)
        else
          render inertia: "CompetitorMonitoring/MonitoringSources/New",
                 props: {
                   competitor: @competitor.as_json,
                   monitoring_source: @source.as_json,
                   errors: @source.errors.messages,
                   enum_options: enum_options
                 },
                 status: :unprocessable_entity
        end
      end

      def edit
        render inertia: "CompetitorMonitoring/MonitoringSources/Edit",
               props: {
                 competitor: @competitor.as_json,
                 monitoring_source: @source.as_json,
                 errors: {},
                 enum_options: enum_options
               }
      end

      def update
        if @source.update(source_params)
          redirect_to admin_competitor_monitoring_competitor_monitoring_sources_path(@competitor)
        else
          render inertia: "CompetitorMonitoring/MonitoringSources/Edit",
                 props: {
                   competitor: @competitor.as_json,
                   monitoring_source: @source.as_json,
                   errors: @source.errors.messages,
                   enum_options: enum_options
                 },
                 status: :unprocessable_entity
        end
      end

      private

      def set_competitor
        @competitor = Competitor.find(params[:competitor_id])
      end

      def set_source
        @source = @competitor.monitoring_sources.find(params[:id])
      end

      def source_params
        params.require(:monitoring_source).permit(
          :name, :url, :source_type, :fetch_strategy,
          :extractor_type, :check_frequency, :active
        )
      end

      def enum_options
        {
          source_types: MonitoringSource.source_types.keys,
          fetch_strategies: MonitoringSource.fetch_strategies.keys,
          extractor_types: MonitoringSource.extractor_types.keys,
          check_frequencies: MonitoringSource.check_frequencies.keys
        }
      end
    end
  end
end
