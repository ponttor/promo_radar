module CompetitorMonitoring
  class FetchInstagramPostsJob
    include Sidekiq::Job

    sidekiq_options queue: :fetch, retry: 3

    def perform(monitoring_source_id, scraper = nil)
      source = MonitoringSource.find(monitoring_source_id)
      new_posts = CompetitorMonitoring::FetchInstagramPosts.call(
        monitoring_source: source,
        scraper: scraper
      )
      new_posts.each { |p| CompetitorMonitoring::AnalyzeInstagramPostJob.perform_async(p.id) }
    rescue CompetitorMonitoring::FetchInstagramPosts::SessionExpiredError => e
      logger.error "Instagram session expired for source #{monitoring_source_id}: #{e.message}"
    end
  end
end
