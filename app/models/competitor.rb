class Competitor < ApplicationRecord
  has_many :monitoring_sources, dependent: :destroy

  validates :name, presence: true

  scope :active, -> { where(active: true) }
end
