class RemoveUsernameConstraint < ActiveRecord::Migration[4.2]
  def change
    change_column_null :users, :username, true
  end
end
