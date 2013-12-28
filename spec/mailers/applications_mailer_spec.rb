require 'spec_helper'

describe ApplicationsMailer do
  let(:application) { create(:application) }

  describe 'when someone submits their application' do
    before do
      application.submit
    end

    describe 'confirmation email' do
      let(:mail) { ApplicationsMailer.confirmation(application) }

      it 'is sent to the applicant' do
        expect(mail.to).to eq([application.user.email])
      end

      it 'includes their name' do
        expect(mail.body).to include(application.user.name)
      end
    end

    describe 'member notification email' do
      before do
        5.times do
          create(:member)
        end
      end

      let(:mail) { ApplicationsMailer.notify_members(application) }

      it 'is sent to current members' do
        expect(mail.to).to include("membership@doubleunion.org")
        expect(mail.bcc.count).to eq(5)
      end

      it "includes the applicant's deets" do
        expect(mail.body).to include(application.user.name)
      end
    end
  end
end
