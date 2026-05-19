class AddUniqueIndexToInstagramCredentialsUsername < ActiveRecord::Migration[7.2]
  def change
    add_index :instagram_credentials, :username, unique: true
  end
end
