class MonitoringSource < ApplicationRecord
  belongs_to :competitor
  has_many :source_snapshots, dependent: :destroy
  has_many :instagram_posts, dependent: :destroy

  enum :source_type, { website: "website", instagram: "instagram" }

  validates :url, presence: true, format: {
    with: /\Ahttps?:\/\/.+/,
    message: "must start with http:// or https://"
  }

  scope :active, -> { where(active: true) }
  scope :instagram, -> { where(source_type: "instagram") }
end
