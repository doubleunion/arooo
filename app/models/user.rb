class User < ApplicationRecord
  include AdminUser

  EMAIL_PATTERN = /\A.+@.+\Z/

  attr_accessible :username, :name, :email, :profile_attributes, :pronounceable_name,
    :application_attributes, :email_for_google, :dues_pledge, :is_scholarship, :voting_policy_agreement

  validates :state, presence: true

  validates :username, presence: true

  validates :email, uniqueness: true, format: {
    with: EMAIL_PATTERN,
    message: "address is invalid"
  }

  validates :dues_pledge, numericality: true, allow_blank: true

  validates :email_for_google,
    presence: true,
    if: :setup_complete,
    format: {with: EMAIL_PATTERN}

  has_one :profile, dependent: :destroy
  has_one :application, dependent: :destroy
  has_one :door_code, dependent: :destroy
  has_many :authentications, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :sponsorships
  has_many :applications, through: :sponsorships

  after_create :create_profile, :create_application
  after_update :update_stripe_record
  accepts_nested_attributes_for :profile, :application

  scope :visitors, -> { where(state: "visitor") }
  scope :applicants, -> { where(state: "applicant") }
  scope :members, -> { where(state: "member") }
  scope :key_members, -> { where(state: "key_member") }
  scope :voting_members, -> { where(state: "voting_member") }

  scope :all_members, -> { where(state: %w[member key_member voting_member]) }

  scope :all_admins, -> { where(is_admin: true) }

  scope :no_stripe_dues, -> {
    all_members
      .where(stripe_customer_id: nil)
  }

  scope :show_public, -> {
    all_members
      .includes(:profile)
      .where('profiles.show_name_on_site': true)
      .where("name IS NOT NULL")
      .order_by_state
  }

  scope :with_submitted_application, -> {
    applicants
      .includes(:profile)
      .includes(:application)
      .where('applications.state': "submitted")
      .order("applications.submitted_at DESC")
  }

  scope :with_started_application, -> {
    applicants
      .includes(:profile)
      .includes(:application)
      .where('applications.state': "started")
      .order("applications.submitted_at DESC")
  }

  scope :new_members, -> {
    all_members
      .where("setup_complete IS NULL or setup_complete = ?", false)
      .includes(:application)
      .order("applications.processed_at ASC")
  }

  scope :order_by_state, -> {
                           order(Arel.sql(<<-EOS
    CASE state
    WHEN 'voting_member' THEN 1
    WHEN 'key_member'    THEN 2
    WHEN 'member'        THEN 3
    WHEN 'applicant'     THEN 4
    WHEN 'visitor'       THEN 5
    ELSE                      6
    END
                           EOS
                             .squish))
                         }

  state_machine :state, initial: :visitor do
    event :make_applicant do
      transition visitor: :applicant
    end

    event :make_member do
      transition [:applicant, :voting_member, :key_member] => :member
    end

    event :make_key_member do
      transition [:member, :voting_member] => :key_member
    end

    event :make_voting_member do
      transition [:member, :key_member] => :voting_member
    end

    event :make_former_member do
      transition [:member, :voting_member, :key_member] => :former_member
    end

    after_transition on: [:make_member, :make_key_member, :make_former_member] do |user, _|
      user.update(voting_policy_agreement: false)
    end

    after_transition on: all - [:key_member] do |user, _|
      user.door_code.update!(enabled: false) if user.door_code
    end

    state :visitor
    state :applicant
    state :member
    state :key_member
    state :voting_member
    state :former_member
  end

  def general_member?
    member? || key_member? || voting_member?
  end

  def gravatar_url(size = 200)
    email = gravatar_email || self.email
    hash = email ? Digest::MD5.hexdigest(email.downcase) : nil
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}"
  end

  def create_profile
    self.profile ||= Profile.create(user_id: id)
  end

  def create_application
    self.application ||= Application.create(user_id: id)
  end

  def update_stripe_record
    return unless stripe_customer_id?

    # we only need to update things in stripe if their
    # name or email changed.
    return unless name_changed? || email_changed?

    Stripe::Customer.update(
      stripe_customer_id,
      name: name,
      email: email
    )
  end

  def display_state
    state.tr("_", " ")
  end

  def logged_in!
    touch :last_logged_in_at
  end

  def voted_on?(application)
    !!vote_for(application)
  end

  def vote_for(application)
    Vote.where(application: application, user: self).first
  end

  def number_applications_needing_vote
    if voting_member?
      n = Application.where(state: "submitted").count - Application.joins("JOIN votes ON votes.application_id = applications.id AND applications.state = 'submitted' AND votes.user_id = #{id}").count
      n == 0 ? nil : n
    end
  end

  def sponsor(application)
    Sponsorship.where(application: application, user: self).first
  end

  def mature?
    general_member? && application.processed_at.present? && application.processed_at <= 14.days.ago
  end

  private

  def gravatar_email
    profile.gravatar_email if profile.gravatar_email.present?
  end

  DEFAULT_PROVIDER = "github"
end

# == Schema Information
#
# Table name: users
#
#  id                           :integer          not null, primary key
#  dues_pledge                  :integer
#  email                        :string
#  email_for_google             :string
#  is_admin                     :boolean          default(FALSE)
#  is_scholarship               :boolean          default(FALSE)
#  last_logged_in_at            :datetime
#  last_stripe_charge_succeeded :datetime
#  membership_note              :text
#  name                         :string
#  pronounceable_name           :string
#  setup_complete               :boolean
#  state                        :string           not null
#  username                     :string
#  voting_policy_agreement      :boolean          default(FALSE)
#  created_at                   :datetime
#  updated_at                   :datetime
#  stripe_customer_id           :string
#
