class AddStateToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :state, :string # TODO: :null => false after backfill
  end
end
