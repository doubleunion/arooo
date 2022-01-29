class MakeDoorCodeUserOptional < ActiveRecord::Migration[6.0]
  def change
    change_column_null :door_codes, :user_id, true
    change_column_default :door_codes, :user_id, nil
  end
end
