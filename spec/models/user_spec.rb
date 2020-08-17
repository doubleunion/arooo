require "spec_helper"

describe User do
  describe "validations" do
    it { is_expected.to validate_presence_of :username }

    describe "email address" do
      let(:existing_user) { create :user }
      let(:new_user) { create :user }

      subject { new_user.update_attributes(email: existing_user.email) }

      it "doesn't allow duplication email addresses" do
        subject
        expect(new_user.valid?).to be_falsey
      end

      it "returns the correct error" do
        subject
        expect(new_user.errors.messages[:email].first).to include("has been taken.")
      end
    end
  end

  it "should be in visitor state by default" do
    expect(User.new.state).to eq("visitor")
  end

  it "should have profile after created" do
    expect(User.new.profile).to be_nil
    expect(create(:user).profile).to be_an_instance_of(Profile)
  end

  it "should accept nested attributes for profile" do
    user = create(:user)
    expect(user.profile.twitter).to be_nil
    user.update_attributes!(profile_attributes: {
      id: user.profile.id,
      twitter: "Horse_ebooks"
    })
    expect(user.profile.twitter).to eq("Horse_ebooks")
  end

  it "should transition from visitor to applicant" do
    user = User.new
    user.username = "sallyride"
    user.email = "cat@example.org"
    user.save!

    expect(user.state).to eq("visitor")
    user.make_applicant!
    expect(user.state).to eq("applicant")
  end

  it "should not transition from visitor to member" do
    user = User.new
    user.username = "sallyride"
    user.email = "cat@example.org"
    user.save!

    expect(user.state).to eq("visitor")
    expect { user.make_member! }.to raise_error(StateMachine::InvalidTransition)
  end

  describe "#make_former_member" do
    let(:member) { create(:member) }

    subject { member.make_former_member }

    it "should transition from member to former_member" do
      expect { subject }.to change { member.state }.from("member").to("former_member")
    end

    context "when member had enabled door code" do
      let(:door_code) { create(:door_code, enabled: true, user: member) }

      it "disables the door code" do
        expect { subject }.to change { door_code.enabled }.from(true).to(false)
      end
    end
  end

  describe "#make_member" do
    let(:member) { create(:key_member) }

    subject { member.make_member }

    it "should transition from key member to member" do
      expect { subject }.to change { member.state }.from("key_member").to("member")
    end

    context "with a voting member" do
      let(:member) { create(:voting_member) }

      it "should remove voting member agreement status" do
        expect { subject }.to change { member.voting_policy_agreement }.from(true).to(false)
      end
    end

    context "with a key member" do
      let(:member) { create(:key_member) }
      let(:door_code) { create(:door_code, enabled: true, user: member) }

      it "disables their door code" do
        expect { subject }.to change { door_code.enabled }.from(true).to(false)
      end
    end
  end

  describe "#make_key_member" do
    let(:member) { create :voting_member }

    subject { member.make_key_member }

    it "should transition from voting_member to member" do
      expect { subject }.to change { member.state }.from("voting_member").to("key_member")
    end

    it "should remove voting member agreement status" do
      expect { subject }.to change { member.voting_policy_agreement }.from(true).to(false)
    end

    context "with an applicant" do
      let(:member) { create :applicant }

      it "should not transition from applicant to key member" do
        expect { subject }.not_to change { member.state }
      end
    end
  end

  describe "#make_voting_member" do
    let(:member) { create(:key_member) }

    subject { member.make_voting_member }

    it "should transition from key member to voting member" do
      expect { subject }.to change { member.state }.from("key_member").to("voting_member")
    end
  end

  describe "#door_code" do
    subject { create(:user) }

    it { is_expected.to have_one(:door_code) }

    it "defaults to nil" do
      new_user = User.create!(name: "Kay Doke", email: "k@example.com", username: "k")
      expect(new_user.door_code).to be_nil
    end
  end
end
