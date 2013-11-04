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

  it 'should be in visitor state by default' do
    User.new.state.should == 'visitor'
  end

  it 'should transition from visitor to applicant' do
    user = User.new
    user.username = 'sallyride'
    user.save!

    user.state.should == 'visitor'
    user.make_applicant!
    user.state.should == 'applicant'
  end

  it 'should not transition from visitor to member' do
    user = User.new
    user.username = 'sallyride'
    user.save!

    user.state.should == 'visitor'
    expect { user.make_member! }.to raise_error(StateMachine::InvalidTransition)
  end
end
