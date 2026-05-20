module CompetitorMonitoring
  class ExtractPromotions
    # Matches "Скидка 20%" (keyword before) OR "20% off/discount/скидк" (keyword after)
    PERCENT_DISCOUNT_RE = /(?:скидк\S*\s+(\d+)\s*%|(\d+)\s*%\s*(?:off|скидк|discount))/i
    CASHBACK_RE         = /(\d+)\s*%\s*cashback/i
    PROMO_CODE_RE       = /(?:promo|код|code|coupon)[:\s]+([A-Z0-9\-]{3,20})/i

    def self.call(source_snapshot:)
      new(source_snapshot).call
    end

    def initialize(source_snapshot)
      @snapshot   = source_snapshot
      @competitor = source_snapshot.monitoring_source.competitor
    end

    def call
      text = @snapshot.visible_text.to_s
      promo_code = extract_promo_code(text)
      candidates = []

      text.scan(PERCENT_DISCOUNT_RE) do |match|
        value = (match[0] || match[1]).to_f
        candidates << build_candidate(
          title:          "#{value.to_i}% discount",
          promo_type:     :discount,
          discount_value: value,
          promo_code:     promo_code
        )
      end

      text.scan(CASHBACK_RE) do |match|
        candidates << build_candidate(
          title:          "#{match[0]}% cashback",
          promo_type:     :cashback,
          discount_value: match[0].to_f,
          promo_code:     promo_code
        )
      end

      candidates
    end

    private

    def extract_promo_code(text)
      m = text.match(PROMO_CODE_RE)
      m ? m[1].upcase : nil
    end

    def build_candidate(**attrs)
      PromotionCandidate.create!(
        source_snapshot:     @snapshot,
        competitor:          @competitor,
        confidence:          0.7,
        raw_extraction_json: { "extraction_method" => "rule_based" },
        **attrs
      )
    end
  end
end
