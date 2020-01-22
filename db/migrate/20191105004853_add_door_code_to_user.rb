class AddDoorCodeToUser < ActiveRecord::Migration
  def change
    add_column :users, :door_code, :string(20)
  end
end
