class Profile < ActiveRecord::Base
  belongs_to :user

  validates :user_id, :presence => true

  validates :bio, :length => { :maximum => 2000 }

  attr_accessible :user_id, :twitter, :facebook, :website, :linkedin, :blog,
    :bio

  def twitter_url
    twitter ? "https://twitter.com/#{twitter.gsub(/@/, '')}" : nil
  end
end
