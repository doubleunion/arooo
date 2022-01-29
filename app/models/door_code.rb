class DoorCode < ApplicationRecord
  # We don't need an "assigned to user" status: can use the user_id field to check if a code belongs to a user
  enum status: {
    # This code is not entered in the physical lock.
    not_in_lock: 'not_in_lock',
    # This code is entered in the physical lock.
    in_lock: 'in_lock',
    # This code was previously assigned to a user and is still available in the lock.
    formerly_assigned_in_lock: 'formerly_assigned_in_lock',
    # This code was previously assigned to a user, and is no longer in the lock.
    # We keep such codes around to avoid code re-use.
    formerly_assigned_not_in_lock: 'formerly_assigned_not_in_lock',
    # Denylisted (assumed to not be in the lock).
    # Used for disallowing easily guessable codes.
    denylisted: 'denylisted'
  }

  # A code without a user is available for assigning to a member
  belongs_to :user, optional: true

  validates :code, presence: true
  validates :code, numericality: { only_integer: true }
  validates :code, length: { minimum: 6 }
  validates_uniqueness_of :code, case_sensitive: false
  validates_uniqueness_of :index_number, if: -> { index_number.present? }

  class << self
    # @return [String] A randomly generated number of the requested length, as a string. May be zero-padded.
    def make_random_code(digits: 7)
      (1..digits).map{ "0123456789".chars.to_a.sample }.join
    end
  end

  def is_assigned?
    return user.present?
  end

  def unassign
    new_status = in_lock? ? :formerly_assigned_in_lock : :formerly_assigned_not_in_lock
    update!(user: nil, status: new_status)
  end
end

# == Schema Information
#
# Table name: door_codes
#
#  id           :integer          not null, primary key
#  code         :string           not null
#  index_number :integer
#  status       :string           default("not_in_lock"), not null
#  created_at   :datetime
#  updated_at   :datetime
#  user_id      :integer
#
# Indexes
#
#  index_door_codes_on_code     (code) UNIQUE
#  index_door_codes_on_user_id  (user_id) UNIQUE
#
