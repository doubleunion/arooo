require "spec_helper"

describe Vote do
  it "should be invalid without user id" do
    expect(Vote.new.tap(&:valid?)).to have_at_least(1).errors_on(:user_id)
  end

  it "should be invalid without application id" do
    expect(Vote.new.tap(&:valid?)).to have_at_least(1).errors_on(:application_id)
  end

  it "should be invalid without value" do
    expect(Vote.new.tap(&:valid?)).to have_at_least(1).errors_on(:value)
  end

  it "should be invalid if voter is member" do
    vote = Vote.new

    vote.user = create(:user, state: :member)
    vote.application = create(:application, user: create(:user, state: :applicant))
    vote.value = true
    expect(vote.valid?).to be_falsey
    expect(vote).to have_at_least(1).errors_on(:user)
  end

  it "should be valid if voter is voting member" do
    vote = Vote.new

    vote.user = create(:user, state: :voting_member)
    vote.application = create(:application, user: create(:user, state: :applicant))
    vote.value = true
    expect(vote.valid?).to be_truthy
  end

  it "should validate uniqueness per user and application" do
    applicant = create(:user, state: :applicant)
    application = create(:application, user: applicant)
    voter = create(:user, state: :voting_member)
    create(:vote, application: application, user: voter)

    invalid = Vote.new(application: application,
                       user: voter,
                       value: true)
    expect(invalid.valid?).to be_falsey
    expect(invalid).to have_at_least(1).error_on(:user_id)
  end

  describe "no? yes?" do
    describe "vote no" do
      let(:vote) { create(:vote, :no) }
      it "is accurate" do
        expect(vote.no?).to eq(true)
        expect(vote.yes?).to eq(false)
      end
    end
    describe "vote yes" do
      let(:vote) { create(:vote, :yes) }
      it "is accurate" do
        expect(vote.no?).to eq(false)
        expect(vote.yes?).to eq(true)
      end
    end
  end

  describe "display_value" do
    let(:vote) { build(:vote, :yes) }
    it "is yes" do
      expect(vote.display_value).to eq("yes")
    end
  end

  describe "user_is_not_applicant" do
    let(:application) { create :application }
    let(:user) { application.user}

    it "does not allow user to vote on their own application" do
      expect { user.vote_for(application) }.to raise_error('???')
    end
  end
end
