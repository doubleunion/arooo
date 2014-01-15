require 'spec_helper'

describe ApplicationsMailer do
  let(:application) { create(:application) }

  before do
    application.submit
  end

  describe 'when someone submits their application' do

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

  describe 'when someone is accepted' do
    before do
      application.approve
    end

    let(:mail) { ApplicationsMailer.approved(application) }

    it 'is sent to the applicant' do
      expect(mail.to).to include(application.user.email)
    end
  end

  describe 'when someone does not have a sponsor after 2 weeks' do
    describe 'no sponsor email' do
      let(:stale_application) { create(:stale_application) }
      let(:mail) { stale_application.no_sponsor_email }

      it 'is sent if application is stale' do
        mail.should deliver_to(stale_application.user.email)
      end
    end
  end
end
