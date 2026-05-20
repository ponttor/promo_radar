require "test_helper"

class PromotionCandidateTest < ActiveSupport::TestCase
  setup do
    @competitor = Competitor.create!(name: "Acme")
    @source = @competitor.monitoring_sources.create!(
      name: "Main", url: "https://example.com",
      source_type: :website, fetch_strategy: :http,
      extractor_type: :hybrid, check_frequency: :daily
    )
    @snapshot = @source.source_snapshots.create!(
      fetched_at: Time.current, status: :success,
      content_hash: "abc", visible_text: "hello"
    )
  end

  test "belongs_to source_snapshot and competitor" do
    candidate = PromotionCandidate.create!(
      source_snapshot: @snapshot,
      competitor: @competitor,
      promo_type: :discount,
      confidence: 0.7,
      raw_extraction_json: { "extraction_method" => "rule_based" }
    )
    assert_equal @snapshot, candidate.source_snapshot
    assert_equal @competitor, candidate.competitor
  end

  test "promo_type enum includes discount, cashback, bonus, bundle, free_shipping" do
    %w[discount cashback bonus bundle free_shipping].each do |t|
      assert_includes PromotionCandidate.promo_types.keys, t
    end
  end
end
