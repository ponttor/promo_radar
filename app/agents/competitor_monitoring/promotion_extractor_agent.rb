# frozen_string_literal: true

class CompetitorMonitoring::PromotionExtractorAgent < ActiveHarness::Agent
  PROMPT_VERSION = "2.0"

  model do
    use      provider: :openrouter, model: "anthropic/claude-haiku-4-5", temperature: 0.1
    fallback provider: :openrouter, model: "meta-llama/llama-3.3-70b-instruct:free"
    fallback provider: :openrouter, model: "qwen/qwen3-coder:free"
    fallback provider: :openrouter, model: "google/gemma-4-31b-it:free"
  end

  format :json

  system_prompt <<~PROMPT
    You are a promotions extractor. Extract all current promotional offers from the provided webpage text.
    Return ONLY valid JSON in this exact format:
    {"promotions": [{"title": "...", "promo_type": "one of: discount, cashback, bonus, bundle, free_shipping",
     "discount_value": null or number, "discount_unit": "percent|fixed|null",
     "promo_code": null or "STRING", "starts_at": null or "YYYY-MM-DD",
     "ends_at": null or "YYYY-MM-DD", "terms_text": "...", "landing_url": "..."}]}
    If no promotions found, return {"promotions": []}.
  PROMPT
end
