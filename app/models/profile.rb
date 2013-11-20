class Profile < ActiveRecord::Base
  belongs_to :user

  validates :user_id, :presence => true

  validates :bio, :length => { :maximum => 2000 }

  attr_protected :id

  def twitter_url
    twitter ? "https://twitter.com/#{twitter.gsub(/@/, '')}" : nil
  end
end
