class Authentication < ApplicationRecord
  AUTH_PROVIDERS = %w[github google_oauth2]

  attr_accessible :provider, :uid

  belongs_to :user

  validates :user, :uid, :provider, presence: true
  validates :uid, uniqueness: {scope: :user_id}
  validates :provider, inclusion: {in: AUTH_PROVIDERS}
end

# == Schema Information
#
# Table name: authentications
#
#  id         :integer          not null, primary key
#  provider   :string
#  uid        :string
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer
#
