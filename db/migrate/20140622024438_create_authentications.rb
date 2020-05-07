class CreateAuthentications < ActiveRecord::Migration[4.2]
  class User < ApplicationRecord
  end

  class Authentication < ApplicationRecord
  end

  def up
    create_table :authentications do |t|
      t.references :user
      t.string :provider
      t.string :uid
      t.timestamps
    end

    User.find_each do |user|
      auth = Authentication.new
      auth.user_id = user.id
      auth.provider = user.provider
      auth.uid = user.uid
      auth.save
    end

    remove_column :users, :provider
    remove_column :users, :uid
  end

  def down
    add_column :users, :provider, :string
    add_column :users, :uid, :string

    Authentication.find_each do |auth|
      user = User.where(id: auth.user_id).first
      user&.update_attributes(provider: auth.provider, uid: auth.uid)
    end

    drop_table :authentications
  end
end
