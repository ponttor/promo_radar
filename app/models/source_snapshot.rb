class SourceSnapshot < ApplicationRecord
  belongs_to :monitoring_source
  has_many :promotion_candidates, dependent: :destroy
  has_many :promotion_versions, dependent: :destroy

  enum :status, { success: "success", failed: "failed", blocked: "blocked" }

  scope :successful, -> { where(status: :success) }
  scope :changed, -> {
    where(status: :success).where(
      "NOT EXISTS (
        SELECT 1 FROM source_snapshots AS prev
        WHERE prev.monitoring_source_id = source_snapshots.monitoring_source_id
          AND prev.status = 'success'
          AND prev.fetched_at < source_snapshots.fetched_at
          AND prev.content_hash = source_snapshots.content_hash
      )"
    )
  }

  def changed_from_previous?
    prev = monitoring_source.source_snapshots
      .successful
      .where.not(id: id)
      .order(fetched_at: :desc)
      .first
    prev.nil? || content_hash != prev.content_hash
  end
end
