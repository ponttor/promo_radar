class Promotion < ApplicationRecord
  belongs_to :competitor
  belongs_to :current_version, class_name: "PromotionVersion", optional: true
  has_many :promotion_versions, dependent: :destroy
  has_many :promotion_events, dependent: :destroy

  enum :status, { active: "active", expired: "expired", unknown: "unknown" }
  enum :promo_type, {
    discount: "discount", cashback: "cashback",
    bonus: "bonus", bundle: "bundle", free_shipping: "free_shipping"
  }
end
