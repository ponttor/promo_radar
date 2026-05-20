module CompetitorMonitoring
  class ExtractSnapshotJob
    include Sidekiq::Job

    sidekiq_options queue: :extract

    def perform(source_snapshot_id)
      snapshot = SourceSnapshot.find(source_snapshot_id)

      candidates = ExtractPromotions.call(source_snapshot: snapshot)

      candidates.each do |candidate|
        NormalizePromotion.call(promotion_candidate: candidate)
        MatchPromotion.call(promotion_candidate: candidate)
      end

      snapshot.monitoring_source.update_column(:last_checked_at, Time.current)
    end
  end
end
