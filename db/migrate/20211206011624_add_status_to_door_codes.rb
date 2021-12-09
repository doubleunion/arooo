class AddStatusToDoorCodes < ActiveRecord::Migration[6.0]
  def change
    add_column :door_codes, :status, :string, null: false, default: "not_in_lock"
  end
end
