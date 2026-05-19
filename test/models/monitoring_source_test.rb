require "test_helper"

class MonitoringSourceTest < ActiveSupport::TestCase
  def valid_attrs
    {
      name: "Main site",
      url: "https://example.com",
      source_type: :website,
      fetch_strategy: :http,
      extractor_type: :hybrid,
      check_frequency: :daily
    }
  end

  setup do
    @competitor = Competitor.create!(name: "Acme")
  end

  test "is valid with required attributes" do
    s = @competitor.monitoring_sources.new(valid_attrs)
    assert s.valid?
  end

  test "is invalid without name" do
    s = @competitor.monitoring_sources.new(valid_attrs.merge(name: ""))
    assert_not s.valid?
    assert_includes s.errors[:name], "can't be blank"
  end

  test "is invalid without url" do
    s = @competitor.monitoring_sources.new(valid_attrs.merge(url: ""))
    assert_not s.valid?
    assert_includes s.errors[:url], "can't be blank"
  end

  test "is invalid with malformed url" do
    s = @competitor.monitoring_sources.new(valid_attrs.merge(url: "not-a-url"))
    assert_not s.valid?
    assert s.errors[:url].any?
  end

  test "accepts https url" do
    s = @competitor.monitoring_sources.new(valid_attrs.merge(url: "https://example.com/promos"))
    assert s.valid?
  end

  test "defaults to active" do
    s = @competitor.monitoring_sources.create!(valid_attrs)
    assert s.active?
  end

  test "active scope excludes inactive sources" do
    @competitor.monitoring_sources.create!(valid_attrs.merge(active: true))
    @competitor.monitoring_sources.create!(valid_attrs.merge(active: false, name: "Inactive"))
    assert_equal 1, MonitoringSource.active.count
  end

  test "source_type enum has expected values" do
    %w[website landing_page app_store instagram facebook twitter youtube].each do |t|
      assert_includes MonitoringSource.source_types.keys, t
    end
  end

  test "fetch_strategy enum has expected values" do
    assert_includes MonitoringSource.fetch_strategies.keys, "http"
    assert_includes MonitoringSource.fetch_strategies.keys, "browser"
  end
end
