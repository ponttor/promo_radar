class CreatePromotionVersions < ActiveRecord::Migration[7.2]
  def up
    create_table :promotion_versions do |t|
      t.references :promotion,       null: false, foreign_key: true
      t.references :source_snapshot, null: false, foreign_key: true
      t.string  :title
      t.text    :description
      t.decimal :discount_value, precision: 10, scale: 2
      t.string  :discount_unit
      t.string  :promo_code
      t.datetime :starts_at
      t.datetime :ends_at
      t.text    :terms_text
      t.string  :landing_url
      t.jsonb   :change_summary_json
      t.string  :version_hash
      t.timestamps
    end

    add_index :promotion_versions, :version_hash
    add_foreign_key :promotions, :promotion_versions, column: :current_version_id
    add_foreign_key :promotion_candidates, :promotions
  end

  def down
    remove_foreign_key :promotion_candidates, :promotions
    remove_foreign_key :promotions, column: :current_version_id
    drop_table :promotion_versions
  end
end
