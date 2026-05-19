class CreateInstagramCredentials < ActiveRecord::Migration[7.2]
  def change
    create_table :instagram_credentials do |t|
      t.string   :username,         null: false
      t.text     :session_json,     null: false
      t.boolean  :active,           null: false, default: true
      t.datetime :last_verified_at
      t.timestamps
    end
  end
end
