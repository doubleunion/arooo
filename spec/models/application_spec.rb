require 'spec_helper'

describe Application do
  describe "validations" do
    it { is_expected.to validate_presence_of :user_id }
  end

  describe '#submit' do
    let(:application) { create(:unsubmitted_application) }

    it 'sends an email to the applicant & members' do
      expect {
        application.submit
      }.to change(ActionMailer::Base.deliveries, :count).by(2)
    end
  end

  describe 'with an approvable application' do
    let(:application) { create(:application) }

    before do
      application.submitted_at = Time.now - 8.days
      expect(application).to receive_message_chain(:yes_votes, :count) { 6 }
      expect(application).to receive_message_chain(:no_votes, :count) { 0 }
      expect(application).to receive_message_chain(:sponsorships, :count) { 1 }
    end

    it "should be approvable" do
      expect(application.approvable?).to be_truthy
    end

    context "with an approvable application that's too new" do
      before do
        application.submitted_at = Time.now
      end

      it "should not be approvable" do
        expect(application.approvable?).to be_falsey
      end
    end
  end

  describe 'with a rejectable application' do
    let(:application) { create(:application) }

    before do
      allow(application).to receive_message_chain(:yes_votes, :count)
      allow(application).to receive_message_chain(:no_votes, :count) { 2 }
      allow(application).to receive_message_chain(:sponsorships, :count) { 0 }
    end

    it "should be rejectable" do
      expect(application.rejectable?).to be_truthy
    end
  end
end
