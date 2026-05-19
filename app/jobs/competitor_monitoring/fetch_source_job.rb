module CompetitorMonitoring
  class FetchSourceJob
    include Sidekiq::Job

    sidekiq_options queue: :fetch, retry: 3

    def perform(monitoring_source_id)
      source = MonitoringSource.find(monitoring_source_id)
      snapshot = CompetitorMonitoring::FetchSource.call(monitoring_source: source)
      CompetitorMonitoring::ExtractSnapshotJob.perform_async(snapshot.id) if snapshot.changed_from_previous?
    end
  end
end
