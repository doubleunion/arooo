require "spec_helper"

describe MemberStatusMailer do
  let(:member) { create :member }

  describe "when someone fill out the keymember form" do
    describe "notification email" do
      let(:mail) { MemberStatusMailer.new_key_member(member) }

      it "is sent to the correct addresses" do
        expect(mail.cc).to include member.email
        expect(mail.to).to include MEMBERSHIP_EMAIL
        expect(mail.to).to include KEYS_EMAIL
      end

      it "includes their name" do
        expect(mail.body).to include(member.name)
      end
    end
  end
end
