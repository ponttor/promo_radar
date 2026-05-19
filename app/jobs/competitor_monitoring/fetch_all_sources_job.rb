module CompetitorMonitoring
  class FetchAllSourcesJob
    include Sidekiq::Job

    def perform
      sources = MonitoringSource.active.to_a
      sources.each do |s|
        if s.source_type == "instagram"
          CompetitorMonitoring::FetchInstagramPostsJob.perform_async(s.id)
        else
          CompetitorMonitoring::FetchSourceJob.perform_async(s.id)
        end
      end
      logger.info "Enqueued #{sources.size} fetch jobs"
    end
  end
end
