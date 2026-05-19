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

ActiveRecord::Schema[7.2].define(version: 2026_05_19_174453) do
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
  add_foreign_key "source_snapshots", "monitoring_sources"
end
