require 'spec_helper'

describe Vote do
  it 'should be invalid without user id' do
    Vote.new.tap(&:valid?).should have_at_least(1).errors_on(:user_id)
  end

  it 'should be invalid without application id' do
    Vote.new.tap(&:valid?).should have_at_least(1).errors_on(:application_id)
  end

  it 'should be invalid without value' do
    Vote.new.tap(&:valid?).should have_at_least(1).errors_on(:value)
  end

  it 'should be invalid if voter is member' do
    vote = Vote.new

    vote.user = User.make!(:member)
    vote.application = Application.make!(user: User.make!(:applicant))
    vote.value = true
    vote.valid?.should be_false
    vote.should have_at_least(1).errors_on(:user)
  end

  it 'should be valid if voter is voting member' do
    vote = Vote.new

    vote.user = User.make!(:voting_member)
    vote.application = Application.make!(user: User.make!(:applicant))
    vote.value = true
    vote.valid?.should be_true
  end

  it 'should validate uniqueness per user and application' do
    applicant   = User.make!(:applicant)
    application = Application.make!(user: applicant)
    voter       = User.make!(:voting_member)
    vote        = Vote.make!(application: application, user: voter)

    invalid = Vote.new(application: application,
                       user: voter,
                       value: true)
    invalid.valid?.should be_false
    invalid.should have_at_least(1).error_on(:user_id)
  end
end
