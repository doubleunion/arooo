class AddUniqueIndexToUsersUsernameAndUid < ActiveRecord::Migration[4.2]
  def change
    add_index :users, [:username, :uid], unique: true
  end
end
