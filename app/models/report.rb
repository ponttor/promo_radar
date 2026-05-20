class Report < ApplicationRecord
  has_many :report_items, dependent: :destroy
  has_many :promotion_events, through: :report_items

  enum :report_type, { daily: "daily", weekly: "weekly", manual: "manual" }

  validates :report_type, presence: true
  validates :generated_at, presence: true
end
