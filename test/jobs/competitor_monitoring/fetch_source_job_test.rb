require "test_helper"
require "sidekiq/testing"

class CompetitorMonitoring::FetchSourceJobTest < ActiveSupport::TestCase
  def valid_source_attrs
    {
      name: "Site", url: "https://example.com",
      source_type: :website, fetch_strategy: :http,
      extractor_type: :hybrid, check_frequency: :daily
    }
  end

  setup do
    Sidekiq::Testing.fake!
    @competitor = Competitor.create!(name: "Acme")
    @source = @competitor.monitoring_sources.create!(valid_source_attrs)
    CompetitorMonitoring::ExtractSnapshotJob.jobs.clear
  end

  teardown { Sidekiq::Testing.disable! }

  test "enqueues ExtractSnapshotJob when content changed (first snapshot)" do
    stub_request(:get, "https://example.com")
      .to_return(status: 200, body: "<html><body>content v1</body></html>")

    assert_difference "CompetitorMonitoring::ExtractSnapshotJob.jobs.size", 1 do
      CompetitorMonitoring::FetchSourceJob.new.perform(@source.id)
    end
  end

  test "does not enqueue ExtractSnapshotJob when content unchanged" do
    stub_request(:get, "https://example.com")
      .to_return(status: 200, body: "<html><body>same content</body></html>")
    CompetitorMonitoring::FetchSourceJob.new.perform(@source.id)
    CompetitorMonitoring::ExtractSnapshotJob.jobs.clear

    stub_request(:get, "https://example.com")
      .to_return(status: 200, body: "<html><body>same content</body></html>")
    assert_no_difference "CompetitorMonitoring::ExtractSnapshotJob.jobs.size" do
      CompetitorMonitoring::FetchSourceJob.new.perform(@source.id)
    end
  end
end
