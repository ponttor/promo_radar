require "test_helper"
require "sidekiq/testing"

class CompetitorMonitoring::FetchInstagramPostsJobTest < ActiveSupport::TestCase
  class MockScraper
    def fetch_posts(url:, session_json:)
      [
        {
          instagram_id: "newpost1", posted_at: 1.hour.ago, post_type: "photo",
          caption: "#test caption", likes_count: 10, comments_count: 2,
          media_url: "https://cdn.example.com/img.jpg",
          permalink: "https://www.instagram.com/p/newpost1/"
        }
      ]
    end
  end

  def setup
    Sidekiq::Testing.fake!
    @competitor = Competitor.create!(name: "Acme")
    @source = @competitor.monitoring_sources.create!(
      name: "Acme IG", url: "https://www.instagram.com/acme/",
      source_type: :instagram, fetch_strategy: :browser,
      extractor_type: :hybrid, check_frequency: :daily
    )
    InstagramCredential.create!(username: "bot", session_json: '{"cookies":[],"origins":[]}', active: true)
    CompetitorMonitoring::AnalyzeInstagramPostJob.jobs.clear
  end

  teardown { Sidekiq::Testing.disable! }

  test "enqueues AnalyzeInstagramPostJob for each new post" do
    assert_difference "CompetitorMonitoring::AnalyzeInstagramPostJob.jobs.size", 1 do
      CompetitorMonitoring::FetchInstagramPostsJob.new.perform(
        @source.id,
        CompetitorMonitoring::FetchInstagramPostsJobTest::MockScraper.new
      )
    end
  end

  test "does not enqueue AnalyzeInstagramPostJob when no new posts" do
    @source.instagram_posts.create!(
      instagram_id: "newpost1", fetched_at: Time.current,
      posted_at: 1.hour.ago, post_type: "photo", caption: "old"
    )
    assert_no_difference "CompetitorMonitoring::AnalyzeInstagramPostJob.jobs.size" do
      CompetitorMonitoring::FetchInstagramPostsJob.new.perform(
        @source.id,
        CompetitorMonitoring::FetchInstagramPostsJobTest::MockScraper.new
      )
    end
  end
end
