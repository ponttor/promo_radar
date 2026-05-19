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

ActiveRecord::Schema[7.2].define(version: 2026_05_19_123729) do
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

  add_foreign_key "monitoring_sources", "competitors"
end
