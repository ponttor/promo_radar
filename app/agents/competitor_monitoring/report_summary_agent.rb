# frozen_string_literal: true

class CompetitorMonitoring::ReportSummaryAgent < ActiveHarness::Agent
  PROMPT_VERSION = "1.0"

  model do
    use      provider: :openrouter, model: "anthropic/claude-haiku-4-5", temperature: 0.4
    fallback provider: :openrouter, model: "meta-llama/llama-3.3-70b-instruct:free"
    fallback provider: :openrouter, model: "qwen/qwen3-coder:free"
  end

  system_prompt <<~PROMPT
    You are a business analyst assistant. Generate a concise executive summary of competitor promotional activity changes.
    Write in clear business language. Be specific about numbers and dates.
    Focus on what changed and why it might matter for the business.
    Return ONLY the summary as plain markdown text (no JSON wrapper).
  PROMPT
end
