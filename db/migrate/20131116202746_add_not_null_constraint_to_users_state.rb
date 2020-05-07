class AddNotNullConstraintToUsersState < ActiveRecord::Migration[4.2]
  def up
    change_column :users, :state, :string, null: false
  end

  def down
    change_column :users, :state, :string, null: true
  end
end
