class AddSetupFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_for_google, :string
    add_column :users, :dues_pledge, :integer
  end
end
