require "digest"

module CompetitorMonitoring
  class NormalizePromotion
    def self.call(promotion_candidate:)
      new(promotion_candidate).call
    end

    def initialize(candidate)
      @candidate = candidate
    end

    def call
      normalized_title = normalize_title(@candidate.title)
      normalized_code  = normalize_promo_code(@candidate.promo_code)
      normalized_value = @candidate.discount_value&.to_f&.round(2)
      fingerprint      = generate_fingerprint(normalized_title, normalized_code)

      @candidate.update!(
        promo_code:     normalized_code,
        discount_value: normalized_value,
        fingerprint:    fingerprint
      )

      { title: normalized_title, promo_code: normalized_code,
        discount_value: normalized_value, fingerprint: fingerprint }
    end

    private

    def normalize_title(title)
      title.to_s.strip.gsub(/\s+/, " ").downcase
    end

    def normalize_promo_code(code)
      code&.strip&.upcase
    end

    def generate_fingerprint(normalized_title, normalized_code)
      parts = [
        @candidate.competitor_id.to_s,
        @candidate.landing_url.to_s,
        normalized_code.to_s,
        normalized_title
      ]
      Digest::SHA256.hexdigest(parts.join("|"))
    end
  end
end
