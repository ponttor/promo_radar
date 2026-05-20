class CreatePromotions < ActiveRecord::Migration[7.2]
  def change
    create_table :promotions do |t|
      t.references :competitor, null: false, foreign_key: true
      t.string  :canonical_title
      t.string  :promo_type
      t.string  :status, null: false, default: "unknown"
      t.datetime :first_seen_at
      t.datetime :last_seen_at
      t.bigint :current_version_id
      t.timestamps
    end

    add_index :promotions, :current_version_id
  end
end
