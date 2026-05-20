require "test_helper"

class CompetitorTest < ActiveSupport::TestCase
  test "is invalid without name" do
    c = Competitor.new
    assert_not c.valid?
    assert_includes c.errors[:name], "can't be blank"
  end

  test "is valid with name only" do
    assert Competitor.new(name: "Acme").valid?
  end

  test "defaults active to true" do
    assert Competitor.create!(name: "Acme").active?
  end

  test "active scope excludes inactive" do
    Competitor.create!(name: "Active Co", active: true)
    Competitor.create!(name: "Inactive Co", active: false)
    assert_includes Competitor.active.pluck(:name), "Active Co"
    assert_not_includes Competitor.active.pluck(:name), "Inactive Co"
  end

  test "creates monitoring_sources via nested attributes" do
    competitor = Competitor.new(
      name: "Test",
      monitoring_sources_attributes: [
        { url: "https://example.com", source_type: "website" }
      ]
    )
    assert competitor.save
    assert_equal 1, competitor.monitoring_sources.count
    assert_equal "https://example.com", competitor.monitoring_sources.first.url
  end

  test "destroys monitoring_source via _destroy flag" do
    competitor = Competitor.create!(name: "Test")
    source = competitor.monitoring_sources.create!(url: "https://example.com", source_type: "website")
    competitor.update!(monitoring_sources_attributes: [ { id: source.id, _destroy: "1" } ])
    assert_equal 0, competitor.monitoring_sources.count
  end
end
