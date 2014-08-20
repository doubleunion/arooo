class Authentication < ActiveRecord::Base
  AUTH_PROVIDERS = %w(github google_oauth2)

  attr_accessible :provider, :uid

  belongs_to :user

  validates :user, :uid, :provider, presence: true
  validates :uid, uniqueness: { scope: :user_id }
  validates :provider, inclusion: { in: AUTH_PROVIDERS,
    message: "%{value} is not a valid provider"
  }
end
