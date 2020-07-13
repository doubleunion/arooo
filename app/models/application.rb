require "state_machine" # from gem state_machine_deuxito

class Application < ApplicationRecord
  belongs_to :user

  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :sponsorships
  has_many :users, through: :sponsorships

  MAXIMUM_NO = 1
  MINIMUM_SPONSORS = 1
  # this used to be a constant called MINIMUM_YES, but since it's now calculated,
  # it should be recalculated more often than however often we restart the app
  def self.minimum_yes_votes
    User.voting_members.count / 2
  end

  attr_protected :id

  validates :user_id, presence: true
  validates :state, presence: true
  validate :validate_agreed, if: :submitted?

  scope :for_applicant, -> {
    includes(:user)
      .where('users.state': "applicant")
  }

  scope :submitted, -> {
    for_applicant
      .where(state: "submitted")
      .order("applications.submitted_at DESC")
  }

  scope :started, -> {
    for_applicant
      .where(state: "started")
      .order("applications.created_at DESC")
  }

  def yes_votes
    @_yes_votes ||= votes.select(&:yes?)
  end

  def no_votes
    @_no_votes ||= votes.select(&:no?)
  end

  def not_voted_count
    @_not_voted_count ||= begin
      User.voting_members.count - votes.size
    end
  end

  def stale?
    submitted_at <= 14.days.ago && !rejectable? && !sponsored
  end

  def no_sponsor_email
    if stale? && stale_email_sent_at.nil?
      ApplicationsMailer.no_sponsor(self).deliver_now.tap do |message|
        touch :stale_email_sent_at
      end
    end
  end

  def votes_threshold_email
    if rejectable? || approvable?
      ApplicationsMailer.votes_threshold(self).deliver_now
    end
  end

  state_machine :state, initial: :started do
    after_transition started: :submitted do |application, _|
      application.touch :submitted_at
      ApplicationsMailer.confirmation(application).deliver_now

      member_emails = User.all_members.pluck(:email).compact
      (member_emails << JOIN_EMAIL).each do |email|
        ApplicationsMailer.notify_member_of_application(application, email).deliver_now
      end
    end

    after_transition submitted: [:approved, :rejected] do |application, transition|
      application.touch :processed_at
    end

    after_transition submitted: :approved do |application|
      application.user.make_member
      ApplicationsMailer.approved(application).deliver_now
    end

    event :submit do
      transition started: :submitted
      transition rejected: :submitted
    end

    event :approve do
      transition submitted: :approved
    end

    event :reject do
      transition submitted: :rejected
    end

    state :started
    state :submitted
    state :approved
    state :rejected
  end

  def approvable?
    enough_yes && few_nos && sponsored
  end

  def rejectable?
    !few_nos
  end

  def sufficient_votes?
    enough_yes || !few_nos
  end

  def self.to_approve
    all.map { |x| x if x.approvable? && x.state == "submitted" }.compact.sort_by { |x| x.submitted_at }
  end

  def self.to_reject
    all.map { |x| x if x.rejectable? && x.state == "submitted" }.compact.sort_by { |x| x.submitted_at }
  end

  def self.not_enough_info
    all.map { |x| x if !x.rejectable? && !x.approvable? && x.state == "submitted" }.compact.sort_by { |x| x.submitted_at }
  end

  private

  def validate_agreed
    unless agreed_to_all?
      errors.add(:base, "Please agree to all terms")
    end
  end

  def agreed_to_all?
    agreement_terms && agreement_policies && agreement_female
  end

  def enough_yes
    yes_votes.count >= self.class.minimum_yes_votes
  end

  def few_nos
    no_votes.count <= MAXIMUM_NO
  end

  def sponsored
    sponsorships.count >= MINIMUM_SPONSORS
  end
end

# == Schema Information
#
# Table name: applications
#
#  id                  :integer          not null, primary key
#  agreement_female    :boolean          default(FALSE), not null
#  agreement_policies  :boolean          default(FALSE), not null
#  agreement_terms     :boolean          default(FALSE), not null
#  processed_at        :datetime
#  stale_email_sent_at :datetime
#  state               :string           not null
#  submitted_at        :datetime
#  created_at          :datetime
#  updated_at          :datetime
#  user_id             :integer
#
# Indexes
#
#  index_applications_on_state    (state)
#  index_applications_on_user_id  (user_id)
#
