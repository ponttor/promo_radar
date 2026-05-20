class ReportItem < ApplicationRecord
  belongs_to :report
  belongs_to :promotion_event

  scope :ordered, -> { order(:sort_order) }
end
