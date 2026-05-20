# frozen_string_literal: true

require "test_helper"

class CompetitorMonitoring::ReportSummaryAgentTest < ActiveSupport::TestCase
  test "inherits from ActiveHarness::Agent" do
    assert CompetitorMonitoring::ReportSummaryAgent < ActiveHarness::Agent
  end

  test "has PROMPT_VERSION constant" do
    assert_equal "1.0", CompetitorMonitoring::ReportSummaryAgent::PROMPT_VERSION
  end

  test "system prompt mentions Slovak language" do
    prompt = CompetitorMonitoring::ReportSummaryAgent.agent_config[:system_prompt]
    assert_includes prompt, "Slovak"
  end

  test "system prompt requests markdown text output" do
    prompt = CompetitorMonitoring::ReportSummaryAgent.agent_config[:system_prompt]
    assert_includes prompt, "markdown"
  end
end
