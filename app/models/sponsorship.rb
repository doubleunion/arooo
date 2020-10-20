class Sponsorship < ApplicationRecord
  belongs_to :user
  belongs_to :application

  validates :user, presence: true
  validates :application, uniqueness: {scope: :user}
end

# == Schema Information
#
# Table name: sponsorships
#
#  id             :integer          not null, primary key
#  created_at     :datetime
#  updated_at     :datetime
#  application_id :integer
#  user_id        :integer
#
