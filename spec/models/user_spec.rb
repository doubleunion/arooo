require 'spec_helper'

describe User do
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

  describe "#remove_key_membership" do
    let(:key_member) { create(:key_member) }

    it 'should transition from member or key_member to former_member' do
      expect do
        key_member.remove_key_membership
      end.to change{key_member.state}.from("key_member").to("member")
    end
  end

  describe "#remove_membership" do
    let(:member) { create(:member) }

    it 'should transition from member or key_member to former_member' do
      expect {member.remove_membership}.to change{member.state}.from("member").to("former_member")
    end
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
end
