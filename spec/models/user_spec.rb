require 'spec_helper'

describe User do
  describe "validations" do
    it { should validate_presence_of :username }

    describe "email address" do
      let(:existing_user) { create :user }
      let(:new_user) { create :user }

      subject { new_user.update_attributes(email: existing_user.email) }

      it "doesn't allow duplication email addresses" do
        subject
        expect(new_user.valid?).to be_false
      end

      it "returns the correct error" do
        subject
        expect(new_user.errors.messages[:email].first).to include("has been taken.")
      end
    end
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
    user.email = 'cat@example.org'
    user.save!

    user.state.should == 'visitor'
    user.make_applicant!
    user.state.should == 'applicant'
  end

  it 'should not transition from visitor to member' do
    user = User.new
    user.username = 'sallyride'
    user.email = 'cat@example.org'
    user.save!

    user.state.should == 'visitor'
    expect { user.make_member! }.to raise_error(StateMachine::InvalidTransition)
  end

  describe "#remove_voting_membership" do
    let(:voting_member) { create(:voting_member) }

    it 'should transition from member or voting_member to former_member' do
      expect do
        voting_member.remove_voting_membership
      end.to change{voting_member.state}.from("voting_member").to("member")
    end
  end

  describe "#remove_membership" do
    let(:member) { create(:member) }

    it 'should transition from member or voting_member to former_member' do
      expect {member.remove_membership}.to change{member.state}.from("member").to("former_member")
    end
  end
end
