class RemoveCommentsFromVotes < ActiveRecord::Migration
  def up
    remove_column :votes, :comments
  end

  def down
    add_column :votes, :comments, :string
  end
end
