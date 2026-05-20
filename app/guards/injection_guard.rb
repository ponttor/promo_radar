class InjectionGuard < ActiveHarness::Agent
  model do
    use      provider: :openrouter, model: "meta-llama/llama-3.3-70b-instruct:free"
    fallback provider: :openrouter, model: "qwen/qwen3-coder:free"
  end
end
