require "digest"

module CompetitorMonitoring
  class MatchPromotion
    def self.call(promotion_candidate:)
      new(promotion_candidate).call
    end

    def initialize(candidate)
      @candidate = candidate
    end

    def call
      existing = find_existing_promotion
      existing ? match_existing(existing) : create_new
    end

    private

    def find_existing_promotion
      prior = PromotionCandidate
        .where(competitor_id: @candidate.competitor_id, fingerprint: @candidate.fingerprint)
        .where.not(id: @candidate.id)
        .where.not(promotion_id: nil)
        .order(created_at: :desc)
        .first
      prior&.promotion
    end

    def create_new
      promotion = Promotion.create!(
        competitor_id:   @candidate.competitor_id,
        canonical_title: @candidate.title,
        promo_type:      @candidate.promo_type,
        status:          :active,
        first_seen_at:   Time.current,
        last_seen_at:    Time.current
      )

      version = create_version(promotion, change_summary_json: nil)
      promotion.update!(current_version: version)

      event = PromotionEvent.create!(
        promotion:       promotion,
        source_snapshot: @candidate.source_snapshot,
        event_type:      :created,
        details_json:    {},
        created_at:      Time.current
      )

      @candidate.update!(promotion: promotion)
      { promotion: promotion, version: version, event: event }
    end

    def match_existing(promotion)
      promotion.update!(last_seen_at: Time.current)

      new_hash = compute_version_hash(@candidate)
      current  = promotion.current_version

      if current.nil? || new_hash != current.version_hash
        summary = build_change_summary(current, @candidate)
        version = create_version(promotion, change_summary_json: summary)
        promotion.update!(current_version: version)

        event = PromotionEvent.create!(
          promotion:       promotion,
          source_snapshot: @candidate.source_snapshot,
          event_type:      :updated,
          details_json:    summary,
          created_at:      Time.current
        )

        @candidate.update!(promotion: promotion)
        { promotion: promotion, version: version, event: event }
      else
        @candidate.update!(promotion: promotion)
        { promotion: promotion, version: current, event: nil }
      end
    end

    def create_version(promotion, change_summary_json:)
      PromotionVersion.create!(
        promotion:           promotion,
        source_snapshot:     @candidate.source_snapshot,
        title:               @candidate.title,
        description:         @candidate.description,
        discount_value:      @candidate.discount_value,
        discount_unit:       @candidate.discount_unit,
        promo_code:          @candidate.promo_code,
        starts_at:           @candidate.starts_at,
        ends_at:             @candidate.ends_at,
        terms_text:          @candidate.terms_text,
        landing_url:         @candidate.landing_url,
        change_summary_json: change_summary_json,
        version_hash:        compute_version_hash(@candidate)
      )
    end

    def compute_version_hash(candidate)
      Digest::SHA256.hexdigest([
        candidate.title.to_s,
        candidate.discount_value.to_s,
        candidate.promo_code.to_s,
        candidate.ends_at.to_s
      ].join("|"))
    end

    def build_change_summary(old_version, candidate)
      return {} if old_version.nil?

      changes = {}
      {
        title:          [ old_version.title,          candidate.title ],
        discount_value: [ old_version.discount_value, candidate.discount_value ],
        promo_code:     [ old_version.promo_code,     candidate.promo_code ],
        ends_at:        [ old_version.ends_at,        candidate.ends_at ]
      }.each do |field, (old_val, new_val)|
        changes[field.to_s] = { "from" => old_val.to_s, "to" => new_val.to_s } if old_val.to_s != new_val.to_s
      end
      changes
    end
  end
end
