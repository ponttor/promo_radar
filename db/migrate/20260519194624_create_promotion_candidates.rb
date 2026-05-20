class CreatePromotionCandidates < ActiveRecord::Migration[7.2]
  def change
    create_table :promotion_candidates do |t|
      t.references :source_snapshot, null: false, foreign_key: true
      t.references :competitor,      null: false, foreign_key: true
      t.bigint  :promotion_id  # FK added after promotions table exists
      t.string  :title
      t.text    :description
      t.string  :promo_type
      t.decimal :discount_value, precision: 10, scale: 2
      t.string  :discount_unit
      t.string  :promo_code
      t.datetime :starts_at
      t.datetime :ends_at
      t.text    :terms_text
      t.string  :landing_url
      t.jsonb   :raw_extraction_json
      t.decimal :confidence, precision: 5, scale: 2
      t.string  :fingerprint
      t.timestamps
    end

    add_index :promotion_candidates, :fingerprint
    add_index :promotion_candidates, [ :competitor_id, :fingerprint ]
    add_index :promotion_candidates, :promotion_id
  end
end
