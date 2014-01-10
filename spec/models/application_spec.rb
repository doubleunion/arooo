require 'spec_helper'

describe Application do
  it 'should be invalid without user id' do
    Application.new.tap(&:valid?).should have_at_least(1).errors_on(:user_id)
  end

  it 'should be valid with user id' do
    application = Application.new
    application.user = User.make!
    application.valid?.should be_true
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
      application.submitted_at = Time.now - 1.weeks
      application.stub_chain(:yes_votes, :count).and_return 6
      application.stub_chain(:no_votes, :count).and_return 0
      application.stub_chain(:sponsorships, :count).and_return 1
    end

    it "should be approvable" do
      expect(application.approvable?).to be_true
    end

    context "with an approvable application that's too new" do
      before do
        application.submitted_at = Time.now
      end

      it "should not be approvable" do
        expect(application.approvable?).to be_false
      end
    end
  end

  describe 'with a rejectable application' do
    let(:application) { create(:application) }

    before do
      application.stub_chain(:yes_votes, :count).and_return
      application.stub_chain(:no_votes, :count).and_return 2
      application.stub_chain(:sponsorships, :count).and_return 0
    end

    it "should be rejectable" do
      expect(application.rejectable?).to be_true
    end
  end
end
