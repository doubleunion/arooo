class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :application

  validates :user_id, :application_id, presence: true

  validates :body, presence: true

  validate :user_is_general_member

  def user_is_general_member
    unless user&.general_member?
      errors.add(:user, "is not a member")
    end
  end
end

# == Schema Information
#
# Table name: comments
#
#  id             :integer          not null, primary key
#  body           :string           not null
#  created_at     :datetime
#  updated_at     :datetime
#  application_id :integer          not null
#  user_id        :integer          not null
#
# Indexes
#
#  index_comments_on_user_id  (user_id)
#
