class CreateReportItems < ActiveRecord::Migration[7.2]
  def change
    create_table :report_items do |t|
      t.references :report,           null: false, foreign_key: true
      t.references :promotion_event,  null: false, foreign_key: true
      t.integer    :sort_order,       default: 0, null: false

      t.timestamps
    end

    add_index :report_items, [ :report_id, :sort_order ]
  end
end
