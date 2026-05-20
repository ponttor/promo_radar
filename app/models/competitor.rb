class Competitor < ApplicationRecord
  has_many :monitoring_sources, dependent: :destroy
  accepts_nested_attributes_for :monitoring_sources, allow_destroy: true

  validates :name, presence: true

  scope :active, -> { where(active: true) }
end
