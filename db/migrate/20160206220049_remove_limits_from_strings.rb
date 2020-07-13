class RemoveLimitsFromStrings < ActiveRecord::Migration[4.2]
  def up
    change_column :applications, :state, :string, limit: nil
    change_column :authentications, :provider, :string, limit: nil
    change_column :authentications, :uid, :string, limit: nil
    change_column :configurables, :name, :string, limit: nil
    change_column :configurables, :value, :string, limit: nil
    change_column :profiles, :twitter, :string, limit: nil
    change_column :profiles, :facebook, :string, limit: nil
    change_column :profiles, :website, :string, limit: nil
    change_column :profiles, :linkedin, :string, limit: nil
    change_column :profiles, :blog, :string, limit: nil
    change_column :profiles, :gravatar_email, :string, limit: nil
    change_column :users, :name, :string, limit: nil
    change_column :users, :email, :string, limit: nil
    change_column :users, :username, :string, limit: nil
    change_column :users, :state, :string, limit: nil
    change_column :users, :email_for_google, :string, limit: nil
  end

  def down
    change_column :applications, :state, :string, limit: 255
    change_column :authentications, :provider, :string, limit: 255
    change_column :authentications, :uid, :string, limit: 255
    change_column :configurables, :name, :string, limit: 255
    change_column :configurables, :value, :string, limit: 255
    change_column :profiles, :twitter, :string, limit: 255
    change_column :profiles, :facebook, :string, limit: 255
    change_column :profiles, :website, :string, limit: 255
    change_column :profiles, :linkedin, :string, limit: 255
    change_column :profiles, :blog, :string, limit: 255
    change_column :profiles, :gravatar_email, :string, limit: 255
    change_column :users, :name, :string, limit: 255
    change_column :users, :email, :string, limit: 255
    change_column :users, :username, :string, limit: 255
    change_column :users, :state, :string, limit: 255
    change_column :users, :email_for_google, :string, limit: 255
  end
end
