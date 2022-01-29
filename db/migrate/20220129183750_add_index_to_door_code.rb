class AddIndexToDoorCode < ActiveRecord::Migration[6.0]
  def change
    add_column :door_codes, :index_number, :integer
  end
end
