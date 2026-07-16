class AddVoteValueToVote < ActiveRecord::Migration[6.0]
  def change
    add_column :votes, :vote_value, :string
  end
end
