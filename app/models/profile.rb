class Profile < ActiveRecord::Base
  belongs_to :user

  validates :user_id, :presence => true

  validates :summary,  :length => { :maximum => 2000 }
  validates :reasons,  :length => { :maximum => 2000 }
  validates :projects, :length => { :maximum => 2000 }
  validates :skills,   :length => { :maximum => 2000 }

  attr_protected :id

  def twitter_url
    twitter.present? ? "https://twitter.com/#{twitter.gsub(/@/, '')}" : nil
  end
end
