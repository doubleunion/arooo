require "spec_helper"

describe Profile do
  it "should be invalid without user id" do
    expect(Profile.new.tap(&:valid?)).to have_at_least(1).errors_on(:user_id)
  end

  it "should be valid with user id" do
    profile = Profile.new
    profile.user = create(:user)
    expect(profile.valid?).to be_truthy
  end
end
