class RemoveTumblrPost < ActiveRecord::Migration[4.2]
  def change
    drop_table :tumblr_posts
  end
end
