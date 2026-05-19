module CompetitorMonitoring
  class AnalyzeInstagramPostJob
    include Sidekiq::Job

    sidekiq_options queue: :extract

    def perform(instagram_post_id)
      logger.info "AnalyzeInstagramPostJob stub: post #{instagram_post_id} — implement in LLM epic"
    end
  end
end
