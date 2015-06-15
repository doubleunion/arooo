class Profile < ActiveRecord::Base
  belongs_to :user

  validates :user_id,  presence: true
  validates :summary,  length: { maximum: 2000 }
  validates :reasons,  length: { maximum: 2000 }
  validates :projects, length: { maximum: 2000 }
  validates :skills,   length: { maximum: 2000 }
  validates :feminism, length: { maximum: 2000 }

  attr_protected :id

  def twitter_url
    twitter.present? ? "https://twitter.com/#{twitter.gsub(/@/, '')}" : nil
  end

  def github_url
    # hacks -- we set username as the auth provider's username, and didn't
    # store it on the auth. We should write a migration, instead, and remove
    # this once we're confident the data looks good.
    return make_github_url(self.user.username) unless self.user.username.include?('@')
  end

  private

  def make_github_url(username)
    "https://github.com/#{username}"
  end
end
