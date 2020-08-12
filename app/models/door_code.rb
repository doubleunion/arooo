class DoorCode < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates_uniqueness_of :user

  validates :code, presence: true
  validates_uniqueness_of :code, case_sensitive: false

  scope :enabled, -> { where(enabled: true) }

  class << self
    # @param user [User] User to assign the new doorcode to.
    # @return [DoorCode] a newly created doorcode, assigned to the given user
    def new_for_user(user)
      # Find a new unused random code.
      code = make_random_code()
      while DoorCode.find_by(code: code)
        code = make_random_code()
      end
      # Assign this random code to the user.
      DoorCode.create!(code: code, user: user)
    end

    # @return [String] A randomly generated number of the requested length, as a string. May be zero-padded.
    def make_random_code(digits: 6)
      (1..digits).map{ "0123456789".chars.to_a.sample }.join
    end
  end
end

# == Schema Information
#
# Table name: door_codes
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  enabled    :boolean          default(FALSE), not null
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer          not null
#
# Indexes
#
#  index_door_codes_on_code     (code) UNIQUE
#  index_door_codes_on_user_id  (user_id) UNIQUE
#
