require 'spec_helper'

describe ApplicationsMailer do
  let(:application) { create(:application) }
  let(:member) { create(:member) }

  describe 'when someone submits their application' do
    describe 'confirmation email' do
      let(:mail) { ApplicationsMailer.confirmation(application) }

      before do
        application.submit
      end

      it 'is sent to the applicant' do
        expect(mail.to).to eq([application.user.email])
      end

      it 'includes their name' do
        expect(mail.body).to include(application.user.name)
      end
    end
  end
end
