# frozen_string_literal: true

require "test_helper"

class CompetitorMonitoring::PromotionExtractorAgentTest < ActiveSupport::TestCase
  test "inherits from ActiveHarness::Agent" do
    assert CompetitorMonitoring::PromotionExtractorAgent < ActiveHarness::Agent
  end

  test "has PROMPT_VERSION constant" do
    assert_equal "2.0", CompetitorMonitoring::PromotionExtractorAgent::PROMPT_VERSION
  end

  test "system prompt specifies JSON promotions format" do
    prompt = CompetitorMonitoring::PromotionExtractorAgent.agent_config[:system_prompt]
    assert_includes prompt, "promotions"
    assert_includes prompt, "promo_type"
    assert_includes prompt, "discount_value"
  end
end
