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
    comment.application = create(:application)
    comment.user = create(:user, state: :member)
    expect(comment.save).to be_truthy
  end

  describe "scope visible_to" do
    let(:member) { create(:member) }
    let(:voting_member) { create(:voting_member) }
    let!(:voting_member_comment) { create(:comment, user: voting_member) }
    let!(:member_comment) { create(:comment, user: member) }

    it "returns all comments for a voting member" do
      expect(Comment.visible_to(voting_member).count).to eq(2)
    end

    it "returns only own comments for non-voting member" do
      expect(Comment.visible_to(member).count).to eq(1)
      expect(Comment.visible_to(member)).to include(member_comment)
      expect(Comment.visible_to(member)).to_not include(voting_member_comment)
    end
  end
end
