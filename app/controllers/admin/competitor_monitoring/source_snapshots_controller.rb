module Admin
  module CompetitorMonitoring
    class SourceSnapshotsController < ApplicationController
      before_action :set_competitor
      before_action :set_monitoring_source

      def index
        snapshots = @monitoring_source.source_snapshots
          .order(fetched_at: :desc)
          .limit(50)
          .to_a
        snapshots_json = snapshots.map do |s|
          s.as_json(only: %i[id fetched_at status http_status content_hash error_message])
           .merge("changed" => s.changed_from_previous?)
        end
        render inertia: "CompetitorMonitoring/SourceSnapshots/Index",
               props: {
                 competitor:         @competitor.as_json,
                 monitoring_source:  @monitoring_source.as_json,
                 snapshots:          snapshots_json
               }
      end

      def show
        snapshot = @monitoring_source.source_snapshots.find(params[:id])
        render inertia: "CompetitorMonitoring/SourceSnapshots/Show",
               props: {
                 competitor:        @competitor.as_json,
                 monitoring_source: @monitoring_source.as_json,
                 snapshot:          snapshot.as_json(except: [:raw_html])
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
