class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :application

  validates :user_id,        :presence => true
  validates :application_id, :presence => true

  validates :value, :inclusion => { :in => [true, false] }

  validates :user_id, :uniqueness => { :scope => :application_id }

  validate :user_is_voting_member
  validate :user_is_not_applicant

  def user_is_voting_member
    unless user && user.voting_member?
      errors.add(:user, 'is not a key member')
    end
  end

  def user_is_not_applicant
    if user == application.try(:user)
      errors.add(:user, 'is applicant')
    end
  end

  def display_value
    value ? 'yes' : 'no'
  end

  def yes?
    value
  end

  def no?
    !value
  end
end
