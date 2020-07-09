class DoorCode < ApplicationRecord
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
