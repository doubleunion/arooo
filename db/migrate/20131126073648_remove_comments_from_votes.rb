class RemoveCommentsFromVotes < ActiveRecord::Migration[4.2]
  def up
    remove_column :votes, :comments
  end

  def down
    add_column :votes, :comments, :string
  end
end
