class CreatePromotionEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :promotion_events do |t|
      t.references :promotion,       null: false, foreign_key: true
      t.references :source_snapshot, null: true,  foreign_key: true
      t.string  :event_type, null: false
      t.jsonb   :details_json
      t.datetime :created_at, null: false
    end

    add_index :promotion_events, [ :promotion_id, :event_type ]
    add_index :promotion_events, :created_at
  end
end
