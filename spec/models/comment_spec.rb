require 'spec_helper'

describe Comment do
  it 'should validate presence of user id' do
    Comment.new.tap(&:valid?).should have_at_least(1).errors_on(:user_id)
  end

  it 'should validate presence of application id' do
    Comment.new.tap(&:valid?).should have_at_least(1).errors_on(:application_id)
  end

  it 'should validate presence of body' do
    Comment.new.tap(&:valid?).should have_at_least(1).errors_on(:body)
  end

  it 'should not be valid for visitor' do
    comment = Comment.new
    comment.user = User.make!(:visitor)
    comment.tap(&:valid?).should have_at_least(1).errors_on(:user)
  end

  it 'should not be valid for applicant' do
    comment = Comment.new(:user => User.make!(:applicant))
    comment.tap(&:valid?).should have_at_least(1).errors_on(:user)
  end

  it 'should be valid for member' do
    comment = Comment.new
    comment.user = User.make!(:member)
    comment.tap(&:valid?).should have(0).errors_on(:user)
  end

  it 'should be valid for key member' do
    comment = Comment.new
    comment.user = User.make!(:voting_member)
    comment.tap(&:valid?).should have(0).errors_on(:user)
  end

  it 'should be saved for member' do
    comment = Comment.new(:body => 'hello')
    comment.application = Application.make!(:with_user)
    comment.user = User.make!(:member)
    comment.save.should be_true
  end
end
