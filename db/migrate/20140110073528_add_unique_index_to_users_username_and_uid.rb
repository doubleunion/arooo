class AddUniqueIndexToUsersUsernameAndUid < ActiveRecord::Migration
  def change
    add_index :users, [:username, :uid], :unique => true
  end
end
