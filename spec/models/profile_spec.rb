require 'spec_helper'

describe Profile do
  it 'should be invalid without user id' do
    Profile.new.tap(&:valid?).should have_at_least(1).errors_on(:user_id)
  end

  it 'should be valid with user id' do
    profile = Profile.new
    profile.user = User.make!
    profile.valid?.should be_true
  end
end
