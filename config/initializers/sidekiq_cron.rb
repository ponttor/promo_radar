unless Rails.env.test?
  Sidekiq::Cron::Job.load_from_hash(
    "fetch_all_sources" => {
      "cron"  => "0 6 * * *",
      "class" => "CompetitorMonitoring::FetchAllSourcesJob",
      "queue" => "default"
    },
    "generate_daily_report" => {
      "cron"  => "0 7 * * *",
      "class" => "GenerateDailyReportJob",
      "queue" => "default"
    }
  )
end
