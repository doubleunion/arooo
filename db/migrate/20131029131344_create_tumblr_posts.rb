class CreateTumblrPosts < ActiveRecord::Migration[4.2]
  def change
    create_table :tumblr_posts do |t|
      t.integer :tumblr_id, null: false, limit: 8
      t.integer :note_count, null: false, default: 0
      t.string :blog_name, null: false
      t.string :post_url, null: false, limit: 1000
      t.string :slug, null: false
      t.string :tumblr_type, null: false
      t.string :state, null: false
      t.string :format, null: false
      t.string :reblog_key, null: false
      t.string :tags, null: false
      t.string :short_url, null: false
      t.string :title, limit: 10000
      t.string :body, limit: 10000
      t.string :caption, limit: 10000
      t.string :photos, limit: 10000
      t.string :api_repr, null: false, limit: 10000
      t.datetime :published_at, null: false
      t.datetime :last_scraped_at, null: false
    end

    add_index :tumblr_posts, :tumblr_id, unique: true
  end
end
