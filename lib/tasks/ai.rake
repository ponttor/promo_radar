# frozen_string_literal: true

namespace :ai do
  desc "Test PromotionExtractorAgent with a real source snapshot. Usage: rails ai:test_extractor[SNAPSHOT_ID]"
  task :test_extractor, [ :snapshot_id ] => :environment do |_, args|
    snapshot_id = args[:snapshot_id]
    abort "Usage: rails ai:test_extractor[SNAPSHOT_ID]" if snapshot_id.blank?

    snapshot = SourceSnapshot.find(snapshot_id)
    input    = "Competitor: #{snapshot.monitoring_source.competitor.name}\n" \
               "URL: #{snapshot.monitoring_source.url}\n\n" \
               "#{snapshot.visible_text}"

    puts "Running PromotionExtractorAgent on snapshot ##{snapshot.id}..."
    puts "Input length: #{input.length} chars"
    puts "-" * 60

    result = CompetitorMonitoring::PromotionExtractorAgent.call(input:)

    puts "Provider:  #{result.provider}"
    puts "Model:     #{result.model}"
    puts "Tokens:    #{result.usage[:total_tokens]}"
    puts "Time:      #{result.execution_time.round(2)}s"
    puts "-" * 60
    puts "Output:"
    puts JSON.pretty_generate(result.parsed)
  rescue ActiveHarness::Errors::AllModelsFailed => e
    puts "ALL MODELS FAILED:"
    puts e.message
  end
end
