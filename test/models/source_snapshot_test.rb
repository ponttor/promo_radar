require "test_helper"

class SourceSnapshotTest < ActiveSupport::TestCase
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

  test "belongs to monitoring_source" do
    s = @source.source_snapshots.create!(
      fetched_at: Time.current, status: :success,
      content_hash: "abc123", visible_text: "hello"
    )
    assert_equal @source, s.monitoring_source
  end

  test "status enum has success, failed, blocked" do
    assert_includes SourceSnapshot.statuses.keys, "success"
    assert_includes SourceSnapshot.statuses.keys, "failed"
    assert_includes SourceSnapshot.statuses.keys, "blocked"
  end

  test "successful scope returns only success snapshots" do
    @source.source_snapshots.create!(fetched_at: 1.hour.ago, status: :success, content_hash: "aaa", visible_text: "v1")
    @source.source_snapshots.create!(fetched_at: Time.current, status: :failed, error_message: "timeout")
    assert_equal 1, SourceSnapshot.successful.count
  end

  test "changed scope returns first occurrence of each hash per source" do
    s1 = @source.source_snapshots.create!(fetched_at: 2.hours.ago, status: :success, content_hash: "aaa", visible_text: "v1")
    s2 = @source.source_snapshots.create!(fetched_at: 1.hour.ago,  status: :success, content_hash: "aaa", visible_text: "v1")
    s3 = @source.source_snapshots.create!(fetched_at: 30.minutes.ago, status: :success, content_hash: "bbb", visible_text: "v2")

    changed = SourceSnapshot.changed.to_a
    assert_includes     changed, s1
    assert_not_includes changed, s2
    assert_includes     changed, s3
  end

  test "changed_from_previous? returns true for first snapshot" do
    s = @source.source_snapshots.create!(
      fetched_at: Time.current, status: :success,
      content_hash: "aaa", visible_text: "v1"
    )
    assert s.changed_from_previous?
  end

  test "changed_from_previous? returns false when hash matches previous" do
    @source.source_snapshots.create!(fetched_at: 1.hour.ago, status: :success, content_hash: "aaa", visible_text: "v1")
    s2 = @source.source_snapshots.create!(fetched_at: Time.current, status: :success, content_hash: "aaa", visible_text: "v1")
    assert_not s2.changed_from_previous?
  end

  test "changed_from_previous? returns true when hash differs from previous" do
    @source.source_snapshots.create!(fetched_at: 1.hour.ago, status: :success, content_hash: "aaa", visible_text: "v1")
    s2 = @source.source_snapshots.create!(fetched_at: Time.current, status: :success, content_hash: "bbb", visible_text: "v2")
    assert s2.changed_from_previous?
  end
end
