require "spec_helper"

describe AccountSetupReminder do
  describe "#send_emails" do
    before { ActionMailer::Base.deliveries = [] }

    let(:deliveries) { ActionMailer::Base.deliveries }
    let(:users) { User.new_members }
    let(:member) { create :member }
    let(:other_member) { create :setup_complete_member }

    subject { AccountSetupReminder.new(users).send_emails }

    #Steps for setup complete: google-email, dues, membership coordinator manual steps (access to google docs/drive, mailing list)

    context "with no reminders needed" do
      it "sends no emails" do
        subject
        expect(deliveries.count).to eq 0
      end
    end

    context "scholarship applicant still waiting for approval after 21 days" do
      before do
        member.request_scholarship
        member.application.update_column(:processed_at, 21.days.ago)
        other_member.application.update_column(:processed_at, 21.days.ago)
      end

      it "sends no emails" do
        subject
        expect(deliveries.count).to eq 0
      end
    end

    context "scholarship applicant got approval within 3 days. But doesn't have setup complete" do
      let(:member) { create :member, requested_scholarship: Time.now, scholarship_since: Time.now }
      before do
        member.application.update_column(:processed_at, 3.days.ago)
        other_member.application.update_column(:processed_at, 3.days.ago)
      end

      it "sends a reminder email (maybe they don't have google email setup?)" do
        subject
        expect(deliveries.count).to eq 1
      end
    end


    context "with one 3 day reminder" do
      before do
        member.application.update_column(:processed_at, 3.days.ago)
        other_member.application.update_column(:processed_at, 3.days.ago)
      end

      it "sends 1 email" do
        subject
        expect(deliveries.count).to eq 1
      end
    end

    context "with one 7 day reminder" do
      before do
        member.application.update_column(:processed_at, 7.days.ago)
        other_member.application.update_column(:processed_at, 7.days.ago)
      end

      it "sends 1 email" do
        subject
        expect(deliveries.count).to eq 1
      end
    end

    context "with one 14 day reminder" do
      before do
        member.application.update_column(:processed_at, 14.days.ago)
        other_member.application.update_column(:processed_at, 14.days.ago)
      end

      it "sends 1 email" do
        subject
        expect(deliveries.count).to eq 1
      end
    end

    context "with one 21 day reminder" do
      before do
        member.application.update_column(:processed_at, 21.days.ago)
        other_member.application.update_column(:processed_at, 21.days.ago)
      end

      it "sends 1 email" do
        subject
        expect(deliveries.count).to eq 1
      end
    end

    context "with one nil processed at" do
      before do
        member.application.update_column(:processed_at, nil)
        other_member.application.update_column(:processed_at, nil)
      end

      it "sends no emails" do
        subject
        expect(deliveries.count).to eq 0
      end
    end
  end
end
