class Comment < ActiveRecord::Base
  attr_accessible :comment, :application_id, :user_id

  belongs_to :user
  belongs_to :application

  validates :comment, presence: true, length: { maximum: 2000 }
end
