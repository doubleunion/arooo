class Profile < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :summary, length: {maximum: 2000}
  validates :reasons, length: {maximum: 2000}
  validates :projects, length: {maximum: 2000}
  validates :skills, length: {maximum: 2000}
  validates :feminism, length: {maximum: 2000}

  attr_protected :id

  def twitter_url
    twitter.present? ? "https://twitter.com/#{twitter.gsub(/@/, "")}" : nil
  end

  def github_url
    # hacks -- we set username as the auth provider's username, and didn't
    # store it on the auth. We should write a migration, instead, and remove
    # this once we're confident the data looks good.
    return make_github_url(user.username) unless user.username.include?("@")
  end

  private

  def make_github_url(username)
    "https://github.com/#{username}"
  end
end

# == Schema Information
#
# Table name: profiles
#
#  id                :integer          not null, primary key
#  attendance        :string(2000)
#  blog              :string
#  facebook          :string
#  feminism          :string(2000)
#  gravatar_email    :string
#  linkedin          :string
#  projects          :string(2000)
#  pronouns          :string
#  reasons           :string(2000)
#  show_name_on_site :boolean          default(FALSE), not null
#  skills            :string(2000)
#  summary           :string(2000)
#  twitter           :string
#  website           :string
#  created_at        :datetime
#  updated_at        :datetime
#  user_id           :integer          not null
#
# Indexes
#
#  index_profiles_on_user_id  (user_id)
#
