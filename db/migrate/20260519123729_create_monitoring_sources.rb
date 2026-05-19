class CreateMonitoringSources < ActiveRecord::Migration[7.2]
  def change
    create_table :monitoring_sources do |t|
      t.references :competitor, null: false, foreign_key: true
      t.string :name, null: false
      t.string :source_type, null: false
      t.string :url, null: false
      t.string :fetch_strategy, null: false, default: "http"
      t.string :extractor_type, null: false, default: "hybrid"
      t.string :check_frequency, null: false, default: "daily"
      t.boolean :active, null: false, default: true
      t.datetime :last_checked_at
      t.timestamps
    end

    add_index :monitoring_sources, :url
  end
end
