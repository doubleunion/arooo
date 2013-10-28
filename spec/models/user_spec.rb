require 'spec_helper'

describe User do
  it 'should be invalid without username' do
    user = User.new
    user.should_not be_valid
    user.should have_at_least(1).errors_on(:username)
  end

  it 'should be saved if valid' do
    user = User.new
    user.username = 'some_valid_username'
    user.save.should == true
  end
end
