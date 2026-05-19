class InstagramPost < ApplicationRecord
  belongs_to :monitoring_source

  validates :instagram_id, presence: true, uniqueness: { scope: :monitoring_source_id }
  validates :fetched_at, presence: true

  scope :recent, -> { order(posted_at: :desc) }
end
