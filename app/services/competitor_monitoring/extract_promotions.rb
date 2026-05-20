# frozen_string_literal: true

module CompetitorMonitoring
  class ExtractPromotions
    PERCENT_DISCOUNT_RE = /(?:скидк\S*\s+(\d+)\s*%|(\d+)\s*%\s*(?:off|скидк|discount))/i
    CASHBACK_RE         = /(\d+)\s*%\s*cashback/i
    PROMO_CODE_RE       = /(?:promo|код|code|coupon)[:\s]+([A-Z0-9\-]{3,20})/i
    FREE_SPINS_RE       = /(\d[\d\s]{0,9})\s*free\s*spin[ovy]*/i
    EURO_AMOUNT_RE      = /(\d{1,3}(?:\s\d{3})+|\d{4,})\s*€/i
    BONUS_TYPE_RE       = /\b((?:vstupný|uvítací|narodeninový|denný|dnešný|welcome|deposit|reload)\s*bonus)\b/i

    EURO_MIN       = 100
    LLM_TEXT_LIMIT = 8_000

    def self.call(source_snapshot:)
      new(source_snapshot).call
    end

    def initialize(source_snapshot)
      @snapshot   = source_snapshot
      @competitor = source_snapshot.monitoring_source.competitor
    end

    def call
      text       = @snapshot.visible_text.to_s
      promo_code = extract_promo_code(text)

      rule_attrs = collect_rule_based(text, promo_code)

      candidate_attrs = if rule_attrs.empty?
        llm_attrs = collect_llm_candidates
        path      = llm_attrs.empty? ? "empty" : "llm_only"
        llm_attrs.map { |a| a.merge(extraction_path: path) }
      else
        rule_attrs.map { |a| a.merge(extraction_path: "rule_based_only") }
      end

      candidate_attrs.map { |attrs| persist_candidate(attrs) }
    end

    private

    def collect_rule_based(text, promo_code)
      candidates = []

      text.scan(PERCENT_DISCOUNT_RE) do |match|
        value = (match[0] || match[1]).to_f
        candidates << base_attrs(
          title: "#{value.to_i}% discount", promo_type: :discount,
          discount_value: value, promo_code: promo_code,
          extraction_method: "rule_based"
        )
      end

      text.scan(CASHBACK_RE) do |match|
        candidates << base_attrs(
          title: "#{match[0]}% cashback", promo_type: :cashback,
          discount_value: match[0].to_f, promo_code: promo_code,
          extraction_method: "rule_based"
        )
      end

      text.scan(FREE_SPINS_RE) do |match|
        value = match[0].gsub(/\s/, "").to_f
        candidates << base_attrs(
          title: "#{value.to_i} free spins", promo_type: :bonus,
          discount_value: value, promo_code: promo_code,
          extraction_method: "rule_based"
        )
      end

      text.scan(EURO_AMOUNT_RE) do |match|
        value = match[0].gsub(/\s/, "").to_f
        next if value < EURO_MIN
        candidates << base_attrs(
          title: "#{value.to_i}€ bonus", promo_type: :bonus,
          discount_value: value, promo_code: promo_code,
          extraction_method: "rule_based"
        )
      end

      text.scan(BONUS_TYPE_RE) do |match|
        candidates << base_attrs(
          title: match[0].downcase, promo_type: :bonus,
          promo_code: promo_code, extraction_method: "rule_based"
        )
      end

      candidates
    end

    def collect_llm_candidates
      text  = @snapshot.visible_text.to_s.slice(0, LLM_TEXT_LIMIT)
      input = "Competitor: #{@competitor.name}\nURL: #{@snapshot.monitoring_source.url}\n\n#{text}"
      result = PromotionExtractorAgent.call(input: input)
      result.parsed&.fetch("promotions", []).to_a.filter_map { |p| llm_promo_to_attrs(p, result) }
    rescue ActiveHarness::Errors::AllModelsFailed => e
      Rails.logger.warn "LLM extraction failed for snapshot #{@snapshot.id}: #{e.message}"
      []
    end

    def llm_promo_to_attrs(promo, result)
      return nil if promo["title"].blank?
      {
        title:               promo["title"].to_s.truncate(255),
        promo_type:          normalize_promo_type(promo["promo_type"]),
        discount_value:      promo["discount_value"],
        discount_unit:       promo["discount_unit"],
        promo_code:          promo["promo_code"],
        terms_text:          promo["terms_text"],
        landing_url:         promo["landing_url"],
        confidence:          0.85,
        raw_extraction_json: {
          "extraction_method" => "llm",
          "llm_model"         => result.model,
          "llm_provider"      => result.provider.to_s,
          "prompt_version"    => PromotionExtractorAgent::PROMPT_VERSION
        }
      }
    end

    def normalize_promo_type(value)
      valid = PromotionCandidate.promo_types.keys
      valid.include?(value) ? value : "bonus"
    end

    def base_attrs(extraction_method:, **attrs)
      {
        confidence:          0.7,
        raw_extraction_json: { "extraction_method" => extraction_method },
        **attrs
      }
    end

    def persist_candidate(attrs)
      json = (attrs.delete(:raw_extraction_json) || {}).dup
      json["extraction_path"] = attrs.delete(:extraction_path)

      PromotionCandidate.create!(
        source_snapshot:     @snapshot,
        competitor:          @competitor,
        raw_extraction_json: json,
        **attrs
      )
    end

    def extract_promo_code(text)
      m = text.match(PROMO_CODE_RE)
      m ? m[1].upcase : nil
    end
  end
end
