class AddSetupFieldsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :email_for_google, :string
    add_column :users, :dues_pledge, :integer
  end
end
