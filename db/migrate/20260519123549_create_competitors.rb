class CreateCompetitors < ActiveRecord::Migration[7.2]
  def change
    create_table :competitors do |t|
      t.string :name, null: false
      t.string :industry
      t.string :country
      t.boolean :active, null: false, default: true
      t.text :notes
      t.timestamps
    end
  end
end
