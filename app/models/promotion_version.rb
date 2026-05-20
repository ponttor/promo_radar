class PromotionVersion < ApplicationRecord
  belongs_to :promotion
  belongs_to :source_snapshot
end
