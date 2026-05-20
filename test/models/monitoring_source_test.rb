require "test_helper"

class MonitoringSourceTest < ActiveSupport::TestCase
  def valid_attrs
    { url: "https://example.com", source_type: :website }
  end

  setup do
    @competitor = Competitor.create!(name: "Acme")
  end

  test "is valid with url and source_type" do
    assert @competitor.monitoring_sources.new(valid_attrs).valid?
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

  test "defaults to active" do
    assert @competitor.monitoring_sources.create!(valid_attrs).active?
  end

  test "active scope excludes inactive" do
    @competitor.monitoring_sources.create!(valid_attrs.merge(active: true))
    @competitor.monitoring_sources.create!(valid_attrs.merge(active: false, url: "https://other.com"))
    assert_equal 1, MonitoringSource.active.count
  end

  test "source_type enum has only website and instagram" do
    assert_equal({ "website" => "website", "instagram" => "instagram" }, MonitoringSource.source_types)
  end

  test "instagram? returns true for instagram sources" do
    s = @competitor.monitoring_sources.create!(url: "https://instagram.com/x", source_type: :instagram)
    assert s.instagram?
  end
end
