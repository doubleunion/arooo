class DoorCode < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates_uniqueness_of :user

  validates :code, presence: true
  validates_uniqueness_of :code, case_sensitive: false

  scope :enabled, -> { where(enabled: true) }
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
