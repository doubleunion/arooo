class RemoveTumblrPost < ActiveRecord::Migration
  def change
    drop_table :tumblr_posts
  end
end
