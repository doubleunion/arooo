class RemoveEnabledFromDoorCodes < ActiveRecord::Migration[6.0]
  def change
    remove_column :door_codes, :enabled, :boolean
  end
end
