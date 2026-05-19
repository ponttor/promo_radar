class GenerateDailyReportJob
  include Sidekiq::Job

  def perform
    logger.info "GenerateDailyReportJob stub — implement in Epic 4"
  end
end
