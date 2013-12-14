class Sponsorship < ActiveRecord::Base
  attr_accessible :user_id, :application_id

  belongs_to :user
  belongs_to :application

  validates :user, :presence => true
end
