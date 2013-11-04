class User < ActiveRecord::Base
  attr_accessible :provider, :uid, :name, :email

  validates :username, :presence => true

  validates :email, :allow_blank => true, :format => {
    :with    => /@/, # more is probably overkill
    :message => 'Invalid email address' }

  state_machine :state, :initial => :visitor do
    event :make_applicant do
      transition :visitor => :applicant
    end

    event :make_member do
      transition :applicant => :member
    end

    event :make_key_member do
      transition :member => :key_member
    end
  end

  def member_or_key_member?
    member? || key_member?
  end

  def self.create_with_omniauth(auth)
    user = User.new

    user.provider = auth['provider']
    user.uid      = auth['uid']
    user.name     = auth['info']['name']
    user.username = auth['extra']['raw_info']['login']
    user.email    = auth['info']['email']

    user.save!
    user
  end

end
