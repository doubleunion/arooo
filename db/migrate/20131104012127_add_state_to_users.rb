class AddStateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :state, :string # TODO: :null => false after backfill
  end
end
