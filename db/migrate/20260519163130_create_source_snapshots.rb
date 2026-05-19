class CreateSourceSnapshots < ActiveRecord::Migration[7.2]
  def change
    create_table :source_snapshots do |t|
      t.references :monitoring_source, null: false, foreign_key: true
      t.datetime :fetched_at, null: false
      t.string   :status, null: false, default: "success"
      t.integer  :http_status
      t.string   :content_hash
      t.text     :raw_html
      t.text     :visible_text
      t.string   :title
      t.jsonb    :meta_json
      t.string   :screenshot_path
      t.string   :error_message
      t.timestamps
    end

    add_index :source_snapshots, [:monitoring_source_id, :fetched_at]
    add_index :source_snapshots, :content_hash
  end
end
