class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :application

  validates :user_id, presence: true
  validates :application_id, presence: true

  validates :value, inclusion: {in: [true, false]}

  validates :user_id, uniqueness: {scope: :application_id}

  validate :user_is_voting_member
  validate :user_is_not_applicant

  def user_is_voting_member
    unless user&.voting_member?
      errors.add(:user, "is not a voting member")
    end
  end

  def user_is_not_applicant
    if user == application.try(:user)
      errors.add(:user, "is applicant")
    end
  end

  def display_value
    value ? "yes" : "no"
  end

  def yes?
    value
  end

  def no?
    !value
  end
end

# == Schema Information
#
# Table name: votes
#
#  id             :integer          not null, primary key
#  value          :boolean          not null
#  created_at     :datetime
#  updated_at     :datetime
#  application_id :integer          not null
#  user_id        :integer          not null
#
# Indexes
#
#  index_votes_on_application_id              (application_id)
#  index_votes_on_user_id                     (user_id)
#  index_votes_on_user_id_and_application_id  (user_id,application_id)
#
