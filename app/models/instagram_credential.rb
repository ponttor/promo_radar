class InstagramCredential < ApplicationRecord
  validates :username, presence: true, uniqueness: true
  validates :session_json, presence: true

  scope :active, -> { where(active: true) }
end
