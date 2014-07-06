class User < ActiveRecord::Base
  EMAIL_PATTERN = /\A.+@.+\Z/

  attr_accessible :username, :name, :email, :profile_attributes,
    :application_attributes, :email_for_google, :dues_pledge

  validates :state, :presence => true

  validates :username, presence: true

  validates :email, :allow_blank => true, uniqueness: true, :format => {
    :with    => EMAIL_PATTERN,
    :message => 'Invalid email address' }

  validates :dues_pledge, numericality: true, allow_blank: true

  validates :email_for_google,
    :presence => true,
    :if       => :setup_complete,
    :format   => { :with => EMAIL_PATTERN }

  validates :dues_pledge,
    :presence => true,
    :if       => :setup_complete

  has_one  :profile,     :dependent => :destroy
  has_one  :application, :dependent => :destroy
  has_many :authentications, dependent: :destroy
  has_many :votes,       :dependent => :destroy
  has_many :comments,    :dependent => :destroy
  has_many :sponsorships
  has_many :applications, :through => :sponsorships

  after_create :create_profile, :create_application
  accepts_nested_attributes_for :profile, :application

  scope :visitors,    -> { where(:state => 'visitor') }
  scope :applicants,  -> { where(:state => 'applicant') }
  scope :members,     -> { where(:state => 'member') }
  scope :key_members, -> { where(:state => 'key_member') }

  scope :members_and_key_members, -> { where(:state => %w(member key_member)) }

  scope :show_public, -> {
    members_and_key_members
    .includes(:profile)
    .where(:'profiles.show_name_on_site' => true)
    .where('name IS NOT NULL')
    .order_by_state
  }

  scope :with_submitted_application, -> {
    applicants
    .includes(:profile)
    .includes(:application)
    .where(:'applications.state' => 'submitted')
    .order('applications.submitted_at DESC')
  }

  scope :with_started_application, -> {
    applicants
    .includes(:profile)
    .includes(:application)
    .where(:'applications.state' => 'started')
    .order('applications.submitted_at DESC')
  }

  scope :new_members, -> {
    members_and_key_members
    .where('setup_complete IS NULL or setup_complete = ?', false)
    .includes(:application)
    .order('applications.processed_at ASC')
  }

  scope :order_by_state, -> { order(<<-eos
    CASE state
    WHEN 'key_member' THEN 1
    WHEN 'member'     THEN 2
    WHEN 'applicant'  THEN 3
    WHEN 'visitor'    THEN 4
    ELSE                   5
    END
    eos
    .squish)}

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

    event :remove_key_membership do
      transition :key_member => :member
    end

    event :remove_membership do
      transition [:member, :key_member] => :former_member
    end

    state :visitor
    state :applicant
    state :member
    state :key_member
    state :former_member
  end

  def member_or_key_member?
    member? || key_member?
  end

  def gravatar_url(size = 200)
    email = gravatar_email || self.email
    hash = email ? Digest::MD5.hexdigest(email.downcase) : nil
    "http://www.gravatar.com/avatar/#{hash}?s=#{size}"
  end

  def create_profile
    self.profile ||= Profile.create(:user_id => id)
  end

  def create_application
    self.application ||= Application.create(:user_id => id)
  end

  def display_state
    state.gsub(/_/, ' ')
  end

  def logged_in!
    touch :last_logged_in_at
  end

  def voted_on?(application)
    !!vote_for(application)
  end

  def vote_for(application)
    Vote.where(:application => application, :user => self).first
  end

  def number_applications_needing_vote
    if self.key_member?
      n = Application.where(state: 'submitted').count - Application.joins("JOIN votes ON votes.application_id = applications.id AND applications.state = 'submitted' AND votes.user_id = #{self.id}").count
      n==0 ? nil : n
    else
      nil
    end
  end

  def sponsor(application)
    Sponsorship.where(:application => application, :user => self).first
  end

  def mature?
    member_or_key_member? && application.processed_at.present? && application.processed_at <= 14.days.ago
  end

  private

  def gravatar_email
    profile.gravatar_email if profile.gravatar_email.present?
  end

  DEFAULT_PROVIDER = 'github'
end
