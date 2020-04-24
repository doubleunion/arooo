require "spec_helper"

describe Comment do
  it "should validate presence of user id" do
    expect(Comment.new.tap(&:valid?)).to have_at_least(1).errors_on(:user_id)
  end

  it "should validate presence of application id" do
    expect(Comment.new.tap(&:valid?)).to have_at_least(1).errors_on(:application_id)
  end

  it "should validate presence of body" do
    expect(Comment.new.tap(&:valid?)).to have_at_least(1).errors_on(:body)
  end

  it "should not be valid for visitor" do
    comment = Comment.new
    comment.user = create(:user, state: :visitor)
    expect(comment.tap(&:valid?)).to have_at_least(1).errors_on(:user)
  end

  it "should not be valid for applicant" do
    comment = Comment.new(user: create(:user, state: :applicant))
    expect(comment.tap(&:valid?)).to have_at_least(1).errors_on(:user)
  end

  it "should be valid for member" do
    comment = Comment.new
    comment.user = create(:user, state: :member)
    expect(comment.tap(&:valid?)).to have(0).errors_on(:user)
  end

  it "should be valid for voting member" do
    comment = Comment.new
    comment.user = create(:user, state: :voting_member)
    expect(comment.tap(&:valid?)).to have(0).errors_on(:user)
  end

  it "should be saved for member" do
    comment = Comment.new(body: "hello")
    user = create(:user, state: :applicant)
    comment.application = create(:application, user: user)
    comment.user = create(:user, state: :member)
    expect(comment.save).to be_truthy
  end
end
