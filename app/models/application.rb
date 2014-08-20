class Application < ActiveRecord::Base
  belongs_to :user

  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :sponsorships
  has_many :users, through: :sponsorships

  MINIMUM_YES = User.voting_members.count/2
  MAXIMUM_NO = 1
  MINIMUM_SPONSORS = 1


  attr_protected :id

  validates :user_id, presence: true
  validates :state, presence: true
  validate :validate_agreed, if: :submitted?

  scope :for_applicant, -> {
    includes(:user)
    .where(:'users.state' => 'applicant')
  }

  scope :submitted, -> {
    for_applicant
    .where(state: 'submitted')
    .order('applications.submitted_at DESC')
  }

  scope :started,   -> {
    for_applicant
    .where(state: 'started')
    .order('applications.created_at DESC')
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
      ApplicationsMailer.no_sponsor(self).deliver.tap do |message|
        touch :stale_email_sent_at
      end
    end
  end

  def votes_threshold_email
    if rejectable? || approvable?
      ApplicationsMailer.votes_threshold(self).deliver
    end
  end

  state_machine :state, initial: :started do
    after_transition started: :submitted do |application, transition|
      ApplicationsMailer.confirmation(application).deliver
      ApplicationsMailer.notify_members(application).deliver
      application.touch :submitted_at
    end

    after_transition submitted: [:approved, :rejected] do |application, transition|
      application.touch :processed_at
    end

    after_transition submitted: :approved do |application|
      application.user.make_member
      ApplicationsMailer.approved(application).deliver
    end

    event :submit do
      transition started: :submitted
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
    enough_yes && few_nos && sponsored && submitted_at < 7.days.ago
  end

  def rejectable?
    !few_nos
  end

  def self.to_approve
    self.all.map { |x| x if x.approvable? && x.state == "submitted" }.compact.sort_by { |x| x.submitted_at }
  end

  def self.to_reject
    self.all.map { |x| x if x.rejectable? && x.state == "submitted" }.compact.sort_by { |x| x.submitted_at }
  end

  def self.not_enough_info
    self.all.map { |x| x if !x.rejectable? && !x.approvable? && x.state == "submitted" }.compact.sort_by { |x| x.submitted_at }
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
    yes_votes.count >= MINIMUM_YES
  end

  def few_nos
    no_votes.count <= MAXIMUM_NO
  end

  def sponsored
    sponsorships.count >= MINIMUM_SPONSORS
  end
end
