module CompetitorMonitoring
  class ExtractSnapshotJob
    include Sidekiq::Job

    sidekiq_options queue: :extract

    def perform(snapshot_id)
      logger.info "ExtractSnapshotJob stub: snapshot #{snapshot_id} — implement in Epic 3"
    end
  end
end
