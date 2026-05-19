require "test_helper"
require "sidekiq/testing"

class CompetitorMonitoring::FetchAllSourcesJobTest < ActiveSupport::TestCase
  def valid_source_attrs(overrides = {})
    {
      name: "Site", url: "https://example.com",
      source_type: :website, fetch_strategy: :http,
      extractor_type: :hybrid, check_frequency: :daily
    }.merge(overrides)
  end

  setup do
    Sidekiq::Testing.fake!
    @competitor = Competitor.create!(name: "Acme")
    CompetitorMonitoring::FetchSourceJob.jobs.clear
  end

  teardown { Sidekiq::Testing.disable! }

  test "enqueues FetchSourceJob for each active source" do
    active = @competitor.monitoring_sources.create!(valid_source_attrs(active: true))
    @competitor.monitoring_sources.create!(valid_source_attrs(name: "Inactive", url: "https://b.com", active: false))

    CompetitorMonitoring::FetchAllSourcesJob.new.perform

    enqueued_ids = CompetitorMonitoring::FetchSourceJob.jobs.map { |j| j["args"].first }
    assert_includes     enqueued_ids, active.id
    assert_equal        1, enqueued_ids.size
  end
end
