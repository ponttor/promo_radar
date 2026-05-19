class MonitoringSource < ApplicationRecord
  belongs_to :competitor
  has_many :source_snapshots, dependent: :destroy
  has_many :instagram_posts, dependent: :destroy

  enum :source_type, {
    website: "website",
    landing_page: "landing_page",
    app_store: "app_store",
    instagram: "instagram",
    facebook: "facebook",
    twitter: "twitter",
    youtube: "youtube"
  }

  enum :fetch_strategy, {
    http: "http",
    browser: "browser",
    manual_upload: "manual_upload"
  }

  enum :extractor_type, {
    css_rules: "css_rules",
    llm_extraction: "llm_extraction",
    hybrid: "hybrid"
  }

  enum :check_frequency, {
    daily: "daily",
    weekly: "weekly"
  }

  validates :name, presence: true
  validates :url, presence: true, format: {
    with: /\Ahttps?:\/\/.+/,
    message: "must start with http:// or https://"
  }

  scope :active, -> { where(active: true) }
  scope :instagram, -> { where(source_type: "instagram") }
end
