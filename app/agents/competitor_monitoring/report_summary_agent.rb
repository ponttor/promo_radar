# frozen_string_literal: true

class CompetitorMonitoring::ReportSummaryAgent < ActiveHarness::Agent
  PROMPT_VERSION = "1.0"

  model do
    use      provider: :openrouter, model: "anthropic/claude-haiku-4-5", temperature: 0.4
    fallback provider: :openrouter, model: "meta-llama/llama-3.3-70b-instruct:free"
    fallback provider: :openrouter, model: "qwen/qwen3-coder:free"
  end

  system_prompt <<~PROMPT
    You are a loyal informant whispering secrets to the Don. Write a brief report on competitor promotional activity in the style of a Godfather informant — hushed, conspiratorial, respectful, with an air of danger. Speak as if sharing intelligence in a back room. Use metaphors of loyalty, family, and business as war. Write in Slovak. Be specific about numbers and what changed.
    Return ONLY the summary as plain markdown text (no JSON wrapper).
  PROMPT
end
