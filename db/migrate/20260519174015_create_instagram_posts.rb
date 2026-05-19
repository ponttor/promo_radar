class CreateInstagramPosts < ActiveRecord::Migration[7.2]
  def change
    create_table :instagram_posts do |t|
      t.references :monitoring_source, null: false, foreign_key: true
      t.string   :instagram_id,   null: false
      t.datetime :posted_at
      t.string   :post_type
      t.text     :caption
      t.jsonb    :hashtags,        default: []
      t.integer  :likes_count,     default: 0
      t.integer  :comments_count,  default: 0
      t.string   :media_url
      t.string   :permalink
      t.datetime :fetched_at,      null: false
      t.timestamps
    end

    add_index :instagram_posts, [:monitoring_source_id, :instagram_id], unique: true
    add_index :instagram_posts, [:monitoring_source_id, :posted_at]
  end
end
