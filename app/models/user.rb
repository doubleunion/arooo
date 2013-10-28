class User < ActiveRecord::Base
  rolify

  attr_accessible :role_ids, :as => :admin
  attr_accessible :provider, :uid, :name, :email

  validates :username, :presence => true

  def self.create_with_omniauth(auth)
    user = User.new

    user.provider = auth['provider']
    user.uid      = auth['uid']
    user.name     = auth['info']['name']
    user.username = auth['extra']['raw_info']['login']
    user.email    = auth['info']['email']

    user.save!
    user
  end

end
