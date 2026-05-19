require "test_helper"

class CompetitorTest < ActiveSupport::TestCase
  test "is invalid without name" do
    c = Competitor.new
    assert_not c.valid?
    assert_includes c.errors[:name], "can't be blank"
  end

  test "is valid with name only" do
    c = Competitor.new(name: "Acme")
    assert c.valid?
  end

  test "defaults active to true" do
    c = Competitor.create!(name: "Acme")
    assert c.active?
  end

  test "active scope excludes inactive" do
    Competitor.create!(name: "Active Co", active: true)
    Competitor.create!(name: "Inactive Co", active: false)
    names = Competitor.active.pluck(:name)
    assert_includes names, "Active Co"
    assert_not_includes names, "Inactive Co"
  end
end
