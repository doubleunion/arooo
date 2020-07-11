class DoorCode < ApplicationRecord
  belongs_to :user

  validates :code, presence: true
  validates_uniqueness_of :code, case_sensitive: false
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
#  user_id    :integer
#
# Indexes
#
#  index_door_codes_on_code  (code) UNIQUE
#
