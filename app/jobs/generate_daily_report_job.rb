class GenerateDailyReportJob
  include Sidekiq::Job

  def perform
    CompetitorMonitoring::DetectPromotionEndings.call
    CompetitorMonitoring::GenerateReport.call(
      report_type: :daily,
      date_range:  1.day.ago..Time.current
    )
  end
end
