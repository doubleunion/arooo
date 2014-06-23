class Authentication < ActiveRecord::Base
  attr_accessible :provider, :uid

  belongs_to :user

  validates :user, :uid, :provider, presence: true
  validates :uid, uniqueness: { scope: :user_id }
  validates :provider, :inclusion => {
    :in      => %w(github),
    :message => "%{value} is not a valid provider" }
end
