# frozen_string_literal: true

module Admin
  module CompetitorMonitoring
    class SourceSnapshotsController < ApplicationController
      before_action :set_competitor_and_source

      def index
        snapshots = @source.source_snapshots.order(fetched_at: :desc).limit(20)
        render inertia: "CompetitorMonitoring/SourceSnapshots/Index", props: {
          competitor: { id: @competitor.id, name: @competitor.name },
          source:     { id: @source.id, url: @source.url },
          snapshots:  snapshots.map { |s| serialize_snapshot(s) }
        }
      end

      def show
        snapshot   = @source.source_snapshots.find(params[:id])
        candidates = snapshot.promotion_candidates.order(confidence: :desc)

        render inertia: "CompetitorMonitoring/SourceSnapshots/Show", props: {
          competitor: { id: @competitor.id, name: @competitor.name },
          source:     { id: @source.id, url: @source.url },
          snapshot:   serialize_snapshot(snapshot),
          candidates: candidates.map { |c| serialize_candidate(c) }
        }
      end

      private

      def set_competitor_and_source
        @competitor = Competitor.find(params[:competitor_id])
        @source     = @competitor.monitoring_sources.find(params[:monitoring_source_id])
      end

      def serialize_snapshot(s)
        {
          id:                   s.id,
          status:               s.status,
          fetched_at:           s.fetched_at,
          content_hash:         s.content_hash,
          visible_text_preview: s.visible_text.to_s.truncate(200)
        }
      end

      def serialize_candidate(c)
        {
          id:                  c.id,
          title:               c.title,
          promo_type:          c.promo_type,
          confidence:          c.confidence.to_f,
          promo_code:          c.promo_code,
          discount_value:      c.discount_value&.to_f,
          raw_extraction_json: c.raw_extraction_json
        }
      end
    end
  end
end
