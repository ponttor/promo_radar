class PromotionCandidate < ApplicationRecord
  belongs_to :source_snapshot
  belongs_to :competitor
  belongs_to :promotion, optional: true

  enum :promo_type, {
    discount: "discount", cashback: "cashback",
    bonus: "bonus", bundle: "bundle", free_shipping: "free_shipping"
  }
end
