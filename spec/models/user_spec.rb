require 'spec_helper'

describe User do
  it 'should be invalid without username' do
    User.new.tap(&:valid?).should have_at_least(1).errors_on(:username)
  end

  it 'should be saved if valid' do
    user = User.new
    user.username = 'some_valid_username'
    user.save.should == true
  end

  it 'should be in visitor state by default' do
    User.new.state.should == 'visitor'
  end

  it 'should have profile after created' do
    User.new.profile.should be_nil
    User.make!.profile.should be_an_instance_of(Profile)
  end

  it 'should accept nested attributes for profile' do
    user = User.make!
    user.profile.twitter.should be_nil
    user.update_attributes!(:profile_attributes => {
      :id      => user.profile.id,
      :twitter => 'Horse_ebooks' })
    user.profile.twitter.should eq('Horse_ebooks')
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

  it 'should be invalid with invalid provider' do
    user = User.new
    user.provider = 'nope'
    user.valid?.should be_false
    user.should have_at_least(1).error_on(:provider)
  end

  it 'should allow valid provider' do
    user = User.new
    user.provider = 'github'
    user.tap(&:valid?).should have(0).errors_on(:provider)
  end

  it 'should allow blank provider' do
    User.new.tap(&:valid?).should have(0).errors_on(:provider)
  end

  it 'should validate uniqueness of username and uid' do
    User.make!(:username => 'username', :uid => '123')

    user = User.new
    user.username = 'username'
    user.uid = '123'

    user.tap(&:valid?).should have_at_least(1).errors_on(:username)
  end

  describe '.create_with_omniauth' do
    it 'should raise exception with invalid auth hash' do
      expect {
        User.create_with_omniauth({'provider' => 'github'})
      }.to raise_error(KeyError)
    end

    it 'should create user with valid auth hash' do
      user = User.create_with_omniauth({
        'provider' => 'github',
        'uid'      => '12345',
        'extra'    => { 'raw_info' => { 'login' => 'someone' } }
      })
    end
  end

  describe '.provision_with_state' do
    it 'should raise exception with invalid state' do
      expect {
        User.provision_with_state('someone', 'nope')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should create user with visitor state' do
      User.provision_with_state('someone', 'visitor').state.should eq('visitor')
    end

    it 'should create user with applicant state' do
      User.provision_with_state('someone', 'applicant').state.should eq('applicant')
    end

    it 'should create user with member state' do
      User.provision_with_state('someone', 'member').state.should eq('member')
    end

    it 'should create user with key member state' do
      User.provision_with_state('someone', 'key_member').state.should eq('key_member')
    end

    it 'should assign username' do
      user = User.provision_with_state('someone', 'visitor')
      user.username.should eq('someone')
    end
  end
end
