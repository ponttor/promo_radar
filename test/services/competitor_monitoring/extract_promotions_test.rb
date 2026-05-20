require "test_helper"

class CompetitorMonitoring::ExtractPromotionsTest < ActiveSupport::TestCase
  setup do
    @competitor = Competitor.create!(name: "Acme")
    @source = @competitor.monitoring_sources.create!(
      url: "https://example.com", source_type: :website
    )
  end

  def stub_llm_agent(result_or_proc)
    agent = CompetitorMonitoring::PromotionExtractorAgent
    original = agent.method(:call)
    if result_or_proc.respond_to?(:call)
      agent.define_singleton_method(:call) { |**| result_or_proc.call }
    else
      agent.define_singleton_method(:call) { |**| result_or_proc }
    end
    yield
  ensure
    agent.define_singleton_method(:call, &original)
  end

  def snapshot_with(text)
    @source.source_snapshots.create!(
      fetched_at: Time.current, status: :success,
      content_hash: Digest::SHA256.hexdigest(text), visible_text: text
    )
  end

  test "extracts percent discount candidate" do
    snap = snapshot_with("Скидка 20% off на все товары")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    assert_equal 1, candidates.size
    assert_equal 20.0, candidates.first.discount_value.to_f
    assert_equal "discount", candidates.first.promo_type
    assert_equal 0.7, candidates.first.confidence.to_f
    assert_equal "rule_based", candidates.first.raw_extraction_json["extraction_method"]
  end

  test "extracts promo code when present alongside discount" do
    snap = snapshot_with("Скидка 20% до 31 мая, промокод SPRING24")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    assert_equal 1, candidates.size
    assert_equal 20.0, candidates.first.discount_value.to_f
    assert_equal "SPRING24", candidates.first.promo_code
  end

  test "extracts cashback candidate" do
    snap = snapshot_with("Get 15% cashback on your order")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    assert_equal 1, candidates.size
    assert_equal "cashback", candidates.first.promo_type
    assert_equal 15.0, candidates.first.discount_value.to_f
  end

  test "returns empty array when no promotions found" do
    snap = snapshot_with("Welcome to our store. We sell great products and amazing things. Join us now for incredible offers and wonderful experiences.")
    mock_result = Struct.new(:parsed, :model, :provider, :usage).new(
      { "promotions" => [] }, "mock-model", "mock-provider", { total_tokens: 100 }
    )
    stub_llm_agent(mock_result) do
      candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
      assert_equal [], candidates
    end
  end

  test "promo code extraction works with code: prefix format" do
    snap = snapshot_with("Save 10% off, use code: SAVE10")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    assert_equal "SAVE10", candidates.first.promo_code
  end

  test "extracts free spins candidate" do
    snap = snapshot_with("50 000 FREE SPINOV stredajšie akcie")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    assert_equal 1, candidates.size
    assert_equal "bonus", candidates.first.promo_type
    assert_equal 50000.0, candidates.first.discount_value.to_f
    assert_equal "50000 free spins", candidates.first.title
  end

  test "extracts euro bonus amount candidate" do
    snap = snapshot_with("VSTUPNÝ BONUS až 10 000 € k vášmu vkladu!")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    euro = candidates.find { |c| c.discount_value.to_f == 10000.0 }
    assert euro, "expected a 10000€ candidate"
    assert_equal "bonus", euro.promo_type
  end

  test "ignores euro amounts below 100" do
    snap = snapshot_with("Minimálny vklad 5 € je vyžadovaný pre všetkých hráčov na našej platforme. Toto je minimálna suma na začatie hry.")
    mock_result = Struct.new(:parsed, :model, :provider, :usage).new(
      { "promotions" => [] }, "mock-model", "mock-provider", { total_tokens: 100 }
    )
    stub_llm_agent(mock_result) do
      candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
      assert_equal [], candidates
    end
  end

  test "extracts named bonus candidate" do
    snap = snapshot_with("NARODENINOVÝ BONUS MonacoBet oslavuje s tebou!")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    assert_equal 1, candidates.size
    assert_equal "bonus", candidates.first.promo_type
    assert_equal "narodeninový bonus", candidates.first.title
  end

  test "extracts welcome bonus" do
    snap = snapshot_with("Welcome Bonus up to 500€")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    named = candidates.find { |c| c.title == "welcome bonus" }
    assert named, "expected a welcome bonus candidate"
  end

  test "rule_based_only extraction_path when rule-based finds something" do
    snap = snapshot_with("Скидка 20% на все товары")
    candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    assert candidates.all? { |c| c.raw_extraction_json["extraction_path"] == "rule_based_only" }
  end

  test "llm_only extraction_path when rule-based empty and LLM succeeds" do
    text = "Добро пожаловать! Лучшие предложения ждут вас. Присоединяйтесь к нашему сообществу и получите исключительные бонусы и щедрые награды. Мы предлагаем лучшие условия для всех игроков."
    snap = snapshot_with(text)
    mock_result = Struct.new(:parsed, :model, :provider, :usage).new(
      { "promotions" => [ { "title" => "Welcome bonus", "promo_type" => "bonus" } ] },
      "claude-haiku", :openrouter, { total_tokens: 150 }
    )
    stub_llm_agent(mock_result) do
      candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
      assert_equal 1, candidates.size
      assert_equal "llm", candidates.first.raw_extraction_json["extraction_method"]
      assert_equal "llm_only", candidates.first.raw_extraction_json["extraction_path"]
      assert_equal 0.85, candidates.first.confidence.to_f
    end
  end

  test "empty result when both rule-based and LLM find nothing" do
    text = "Добро пожаловать! Это просто информационная страница с подробным описанием нашего сервиса и условиями использования. Добро пожаловать к нам сегодня!"
    snap = snapshot_with(text)
    mock_result = Struct.new(:parsed, :model, :provider, :usage).new(
      { "promotions" => [] }, "claude-haiku", :openrouter, { total_tokens: 150 }
    )
    stub_llm_agent(mock_result) do
      candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
      assert_empty candidates
    end
  end

  test "llm not called when rule-based finds candidates" do
    snap = snapshot_with("Скидка 20% на все товары")
    called = false
    stub_llm_agent(-> { called = true }) do
      CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
    end
    assert_not called, "LLM should not be called when rule-based found candidates"
  end

  test "llm failure handled gracefully returns empty" do
    text = "Добро пожаловать! Это просто информационная страница с подробным описанием нашего сервиса и условиями использования. Добро пожаловать к нам сегодня!"
    snap = snapshot_with(text)
    stub_llm_agent(-> { raise ActiveHarness::Errors::AllModelsFailed, "all failed" }) do
      candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
      assert_empty candidates
    end
  end

  test "returns empty array without calling LLM when visible_text shorter than 100 chars" do
    short_text = "Hi"
    snap = snapshot_with(short_text)
    called = false
    stub_llm_agent(-> { called = true }) do
      candidates = CompetitorMonitoring::ExtractPromotions.call(source_snapshot: snap)
      assert_equal [], candidates
      assert_not called, "LLM should not be called for short text"
    end
  end
end
