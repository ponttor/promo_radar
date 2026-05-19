require "test_helper"

class CompetitorMonitoring::FetchSourceTest < ActiveSupport::TestCase
  def valid_source_attrs
    {
      name: "Main site", url: "https://example.com",
      source_type: :website, fetch_strategy: :http,
      extractor_type: :hybrid, check_frequency: :daily
    }
  end

  setup do
    @competitor = Competitor.create!(name: "Acme")
    @source = @competitor.monitoring_sources.create!(valid_source_attrs)
  end

  test "creates successful snapshot with visible_text and content_hash" do
    stub_request(:get, "https://example.com").to_return(
      status: 200,
      body: "<html><head><title>Promo Page</title></head><body><p>Hello world</p><script>alert(1)</script></body></html>",
      headers: { "Content-Type" => "text/html" }
    )

    snapshot = CompetitorMonitoring::FetchSource.call(monitoring_source: @source)

    assert snapshot.persisted?
    assert_equal "success", snapshot.status
    assert_equal 200, snapshot.http_status
    assert_includes snapshot.visible_text, "Hello world"
    assert_not_includes snapshot.visible_text.to_s, "alert"
    assert_equal "Promo Page", snapshot.title
    assert_equal 64, snapshot.content_hash.length
  end

  test "extracts meta tags into meta_json" do
    stub_request(:get, "https://example.com").to_return(
      status: 200,
      body: '<html><head><meta name="description" content="Best promos"/></head><body>text</body></html>',
      headers: { "Content-Type" => "text/html" }
    )

    snapshot = CompetitorMonitoring::FetchSource.call(monitoring_source: @source)

    assert_equal "Best promos", snapshot.meta_json["description"]
  end

  test "creates failed snapshot on timeout" do
    stub_request(:get, "https://example.com").to_timeout

    snapshot = CompetitorMonitoring::FetchSource.call(monitoring_source: @source)

    assert_equal "failed", snapshot.status
    assert_equal "timeout", snapshot.error_message
  end

  test "creates failed snapshot on 404" do
    stub_request(:get, "https://example.com").to_return(status: 404, body: "Not found")

    snapshot = CompetitorMonitoring::FetchSource.call(monitoring_source: @source)

    assert_equal "failed", snapshot.status
    assert_equal 404, snapshot.http_status
  end

  test "creates blocked snapshot on 403" do
    stub_request(:get, "https://example.com").to_return(status: 403, body: "Forbidden")

    snapshot = CompetitorMonitoring::FetchSource.call(monitoring_source: @source)

    assert_equal "blocked", snapshot.status
    assert_equal 403, snapshot.http_status
  end

  test "creates blocked snapshot on 429" do
    stub_request(:get, "https://example.com").to_return(status: 429, body: "Too many requests")

    snapshot = CompetitorMonitoring::FetchSource.call(monitoring_source: @source)

    assert_equal "blocked", snapshot.status
  end

  test "updates last_checked_at after successful fetch" do
    stub_request(:get, "https://example.com").to_return(status: 200, body: "<html><body>hi</body></html>")

    assert_nil @source.last_checked_at
    CompetitorMonitoring::FetchSource.call(monitoring_source: @source)
    assert_not_nil @source.reload.last_checked_at
  end

  test "updates last_checked_at even after timeout" do
    stub_request(:get, "https://example.com").to_timeout

    CompetitorMonitoring::FetchSource.call(monitoring_source: @source)
    assert_not_nil @source.reload.last_checked_at
  end
end
