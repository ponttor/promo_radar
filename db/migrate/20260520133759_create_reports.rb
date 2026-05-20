class CreateReports < ActiveRecord::Migration[7.2]
  def change
    create_table :reports do |t|
      t.string   :report_type,      null: false
      t.jsonb    :scope_json,        default: {}
      t.text     :summary_markdown
      t.text     :summary_html
      t.datetime :generated_at,     null: false

      t.timestamps
    end

    add_index :reports, :generated_at
    add_index :reports, :report_type
  end
end
