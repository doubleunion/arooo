require "spec_helper"

describe Application do
  let(:application) { create :application }

  describe "validations" do
    it { is_expected.to validate_presence_of :user_id }
  end

  describe "#submit" do
    let(:application) { create(:unsubmitted_application) }

    it "sends an email to the applicant & members" do
      expect {
        application.submit
      }.to change(ActionMailer::Base.deliveries, :count).by(2)
      expect(application.reload.submitted_at).to be_present
    end
  end

  describe "#approve" do
    let(:application) { create(:approvable_application) }
    let(:user) { application.user }

    subject { application.approve }

    it "sends an email to the applicant" do
      expect { subject }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end

    it "marks processed_at" do
      subject
      expect(application.reload.processed_at).to be_present
    end

    it "makes them a member" do
      expect { subject }.to change { user.state }.from("applicant").to("member")
    end
  end

  describe "approve after rejection" do
    let(:application) { create(:application) }
    let(:user) { application.user }

    before do
      allow(application).to receive_message_chain(:yes_votes, :count)
      allow(application).to receive_message_chain(:no_votes, :count) { 2 }
      allow(application).to receive_message_chain(:sponsorships, :count) { 0 }
    end

    it "should be rejectable, rejected, then re-voted and approvable" do
      expect(application.rejectable?).to be_truthy
      application.reject

      # re-submit
      application.submit! # this causes: Cannot transition state via :submit from :rejected (Reason(s): State cannot transition via "submit")
      expect(Application.submitted).to include(application)
      # TODO - figure out what to do with the previous voting round no votes? Delete them? Or just don't count them?
    end
  end

  describe "#approvable?" do
    before do
      expect(application).to receive_message_chain(:yes_votes, :count) { 6 }
      expect(application).to receive_message_chain(:no_votes, :count) { 0 }
      expect(application).to receive_message_chain(:sponsorships, :count) { 1 }
    end

    it "should be approvable" do
      expect(application.approvable?).to be_truthy
    end
  end

  describe "#rejectable?" do
    before do
      allow(application).to receive_message_chain(:yes_votes, :count)
      allow(application).to receive_message_chain(:no_votes, :count) { 2 }
      allow(application).to receive_message_chain(:sponsorships, :count) { 0 }
    end

    it "should be rejectable" do
      expect(application.rejectable?).to be_truthy
    end
  end

  describe "#sufficient_votes?" do
    subject { application.sufficient_votes? }

    before do
      5.times do
        create :voting_member
      end
    end

    context "with enough yes votes" do
      before do
        expect(application).to receive_message_chain(:yes_votes, :count) { 4 }
      end

      it { is_expected.to be true }
    end

    context "with enough no votes" do
      before do
        allow(application).to receive_message_chain(:yes_votes, :count) { 1 }
        allow(application).to receive_message_chain(:no_votes, :count) { 2 }
      end

      it { is_expected.to be true }
    end

    context "with enough yes AND no votes" do
      before do
        allow(application).to receive_message_chain(:yes_votes, :count) { 3 }
        allow(application).to receive_message_chain(:no_votes, :count) { 2 }
      end

      it { is_expected.to be true }
    end

    context "with not enough votes" do
      before do
        allow(application).to receive_message_chain(:yes_votes, :count) { 1 }
        allow(application).to receive_message_chain(:no_votes, :count) { 1 }
      end

      it { is_expected.to be false }
    end
  end
end
