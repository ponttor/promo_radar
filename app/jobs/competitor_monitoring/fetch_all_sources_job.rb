module CompetitorMonitoring
  class FetchAllSourcesJob
    include Sidekiq::Job

    def perform
      sources = MonitoringSource.active.to_a
      sources.each { |s| CompetitorMonitoring::FetchSourceJob.perform_async(s.id) }
      logger.info "Enqueued #{sources.size} fetch jobs"
    end
  end
end
