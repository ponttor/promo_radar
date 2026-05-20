class PromotionEvent < ApplicationRecord
  belongs_to :promotion
  belongs_to :source_snapshot, optional: true

  enum :event_type, {
    created: "created", updated: "updated",
    ended: "ended", reappeared: "reappeared"
  }
end
