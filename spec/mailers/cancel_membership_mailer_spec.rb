require "spec_helper"

describe CancelMembershipMailer do
  let(:member) { create :member }

  describe "when cancellation email" do
    let(:mail) { CancelMembershipMailer.cancel(member) }

    it "is sent to the correct addresses" do
      expect(mail.to).to include MEMBERSHIP_EMAIL
      expect(mail.cc).to include member.email
    end

    it "has the right subject" do
      expect(mail.subject).to include member.name
    end

    it "has the correct information" do
      expect(mail.body).to eq "Please remove #{member.name} from DU mailing lists and Slack."
    end
  end
end
