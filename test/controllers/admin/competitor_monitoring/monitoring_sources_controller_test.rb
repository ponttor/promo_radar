require "test_helper"
require "minitest/mock"

class Admin::CompetitorMonitoring::MonitoringSourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @competitor = Competitor.create!(name: "Acme")
    @website_source = @competitor.monitoring_sources.create!(
      url: "https://acme.com", source_type: :website
    )
    @instagram_source = @competitor.monitoring_sources.create!(
      url: "https://www.instagram.com/acme/", source_type: :instagram
    )
  end

  test "POST fetch for website calls FetchSource and redirects to promotions" do
    mock_snapshot = Minitest::Mock.new
    mock_snapshot.expect :success?, false

    CompetitorMonitoring::FetchSource.stub :call, mock_snapshot do
      post fetch_admin_competitor_monitoring_competitor_monitoring_source_path(
        @competitor, @website_source
      )
    end

    assert_redirected_to admin_competitor_monitoring_promotions_path
    mock_snapshot.verify
  end

  test "POST fetch for website runs extraction when snapshot succeeds" do
    mock_snapshot = Minitest::Mock.new
    mock_snapshot.expect :success?, true

    CompetitorMonitoring::FetchSource.stub :call, mock_snapshot do
      CompetitorMonitoring::ExtractPromotions.stub :call, [] do
        post fetch_admin_competitor_monitoring_competitor_monitoring_source_path(
          @competitor, @website_source
        )
      end
    end

    assert_redirected_to admin_competitor_monitoring_promotions_path
  end

  test "POST fetch for instagram redirects to instagram posts" do
    CompetitorMonitoring::FetchInstagramPosts.stub :call, [] do
      post fetch_admin_competitor_monitoring_competitor_monitoring_source_path(
        @competitor, @instagram_source
      )
    end

    assert_redirected_to admin_competitor_monitoring_competitor_monitoring_source_instagram_posts_path(
      @competitor, @instagram_source
    )
  end

  test "POST fetch rescues error and redirects to competitor edit with alert" do
    CompetitorMonitoring::FetchSource.stub :call, ->(_) { raise "Connection refused" } do
      post fetch_admin_competitor_monitoring_competitor_monitoring_source_path(
        @competitor, @website_source
      )
    end

    assert_redirected_to edit_admin_competitor_monitoring_competitor_path(@competitor)
    assert_equal "Connection refused", flash[:alert]
  end
end
