class Application < ActiveRecord::Base
  belongs_to :user

  has_many :votes

  validates :user_id, :presence => true

  attr_protected :id

  validates :state, :presence => true

  validates :summary,  :length => { :maximum => 2000 }
  validates :reasons,  :length => { :maximum => 2000 }
  validates :projects, :length => { :maximum => 2000 }
  validates :skills,   :length => { :maximum => 2000 }

  validate :validate_agreed, :if => :submitted?

  scope :submitted, -> { where(:state => 'submitted').order('submitted_at DESC') }

  def yes_votes
    @_yes_votes ||= votes.select(&:no?)
  end

  def no_votes
    @_no_votes ||= votes.select(&:no?)
  end

  def not_voted_count
    @_not_voted_count ||= begin
      User.members_and_key_members.count - votes.size
    end
  end

  state_machine :state, :initial => :started do
    after_transition :started => :submitted do |application, transition|
      application.touch :submitted_at
    end

    after_transition :submitted => [:approved, :rejected] do |application, transition|
      application.touch :processed_at
    end

    event :submit do
      transition :started => :submitted
    end

    event :approve do
      transition :submitted => :approved
    end

    event :reject do
      transition :submitted => :rejected
    end

    state :started
    state :submitted
    state :approved
    state :rejected
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
end
