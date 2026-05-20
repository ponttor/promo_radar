# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_05_19_194928) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "competitors", force: :cascade do |t|
    t.string "name", null: false
    t.string "industry"
    t.string "country"
    t.boolean "active", default: true, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "instagram_credentials", force: :cascade do |t|
    t.string "username", null: false
    t.text "session_json", null: false
    t.boolean "active", default: true, null: false
    t.datetime "last_verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_instagram_credentials_on_username", unique: true
  end

  create_table "instagram_posts", force: :cascade do |t|
    t.bigint "monitoring_source_id", null: false
    t.string "instagram_id", null: false
    t.datetime "posted_at"
    t.string "post_type"
    t.text "caption"
    t.jsonb "hashtags", default: []
    t.integer "likes_count", default: 0
    t.integer "comments_count", default: 0
    t.string "media_url"
    t.string "permalink"
    t.datetime "fetched_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["monitoring_source_id", "instagram_id"], name: "index_instagram_posts_on_monitoring_source_id_and_instagram_id", unique: true
    t.index ["monitoring_source_id", "posted_at"], name: "index_instagram_posts_on_monitoring_source_id_and_posted_at"
    t.index ["monitoring_source_id"], name: "index_instagram_posts_on_monitoring_source_id"
  end

  create_table "monitoring_sources", force: :cascade do |t|
    t.bigint "competitor_id", null: false
    t.string "name", null: false
    t.string "source_type", null: false
    t.string "url", null: false
    t.string "fetch_strategy", default: "http", null: false
    t.string "extractor_type", default: "hybrid", null: false
    t.string "check_frequency", default: "daily", null: false
    t.boolean "active", default: true, null: false
    t.datetime "last_checked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competitor_id"], name: "index_monitoring_sources_on_competitor_id"
    t.index ["url"], name: "index_monitoring_sources_on_url"
  end

  create_table "promotion_candidates", force: :cascade do |t|
    t.bigint "source_snapshot_id", null: false
    t.bigint "competitor_id", null: false
    t.bigint "promotion_id"
    t.string "title"
    t.text "description"
    t.string "promo_type"
    t.decimal "discount_value", precision: 10, scale: 2
    t.string "discount_unit"
    t.string "promo_code"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text "terms_text"
    t.string "landing_url"
    t.jsonb "raw_extraction_json"
    t.decimal "confidence", precision: 5, scale: 2
    t.string "fingerprint"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competitor_id", "fingerprint"], name: "index_promotion_candidates_on_competitor_id_and_fingerprint"
    t.index ["competitor_id"], name: "index_promotion_candidates_on_competitor_id"
    t.index ["fingerprint"], name: "index_promotion_candidates_on_fingerprint"
    t.index ["promotion_id"], name: "index_promotion_candidates_on_promotion_id"
    t.index ["source_snapshot_id"], name: "index_promotion_candidates_on_source_snapshot_id"
  end

  create_table "promotion_events", force: :cascade do |t|
    t.bigint "promotion_id", null: false
    t.bigint "source_snapshot_id"
    t.string "event_type", null: false
    t.jsonb "details_json"
    t.datetime "created_at", null: false
    t.index ["created_at"], name: "index_promotion_events_on_created_at"
    t.index ["promotion_id", "event_type"], name: "index_promotion_events_on_promotion_id_and_event_type"
    t.index ["promotion_id"], name: "index_promotion_events_on_promotion_id"
    t.index ["source_snapshot_id"], name: "index_promotion_events_on_source_snapshot_id"
  end

  create_table "promotion_versions", force: :cascade do |t|
    t.bigint "promotion_id", null: false
    t.bigint "source_snapshot_id", null: false
    t.string "title"
    t.text "description"
    t.decimal "discount_value", precision: 10, scale: 2
    t.string "discount_unit"
    t.string "promo_code"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text "terms_text"
    t.string "landing_url"
    t.jsonb "change_summary_json"
    t.string "version_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["promotion_id"], name: "index_promotion_versions_on_promotion_id"
    t.index ["source_snapshot_id"], name: "index_promotion_versions_on_source_snapshot_id"
    t.index ["version_hash"], name: "index_promotion_versions_on_version_hash"
  end

  create_table "promotions", force: :cascade do |t|
    t.bigint "competitor_id", null: false
    t.string "canonical_title"
    t.string "promo_type"
    t.string "status", default: "unknown", null: false
    t.datetime "first_seen_at"
    t.datetime "last_seen_at"
    t.bigint "current_version_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["competitor_id"], name: "index_promotions_on_competitor_id"
    t.index ["current_version_id"], name: "index_promotions_on_current_version_id"
  end

  create_table "source_snapshots", force: :cascade do |t|
    t.bigint "monitoring_source_id", null: false
    t.datetime "fetched_at", null: false
    t.string "status", default: "success", null: false
    t.integer "http_status"
    t.string "content_hash"
    t.text "raw_html"
    t.text "visible_text"
    t.string "title"
    t.jsonb "meta_json"
    t.string "screenshot_path"
    t.string "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_hash"], name: "index_source_snapshots_on_content_hash"
    t.index ["monitoring_source_id", "fetched_at"], name: "index_source_snapshots_on_monitoring_source_id_and_fetched_at"
    t.index ["monitoring_source_id"], name: "index_source_snapshots_on_monitoring_source_id"
  end

  add_foreign_key "instagram_posts", "monitoring_sources"
  add_foreign_key "monitoring_sources", "competitors"
  add_foreign_key "promotion_candidates", "competitors"
  add_foreign_key "promotion_candidates", "promotions"
  add_foreign_key "promotion_candidates", "source_snapshots"
  add_foreign_key "promotion_events", "promotions"
  add_foreign_key "promotion_events", "source_snapshots"
  add_foreign_key "promotion_versions", "promotions"
  add_foreign_key "promotion_versions", "source_snapshots"
  add_foreign_key "promotions", "competitors"
  add_foreign_key "promotions", "promotion_versions", column: "current_version_id"
  add_foreign_key "source_snapshots", "monitoring_sources"
end
