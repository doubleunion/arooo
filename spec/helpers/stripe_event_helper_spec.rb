require 'spec_helper'
require 'stripe_mock'

describe StripeEventHelper do
  before { StripeMock.start }
  after { StripeMock.stop }

  describe "ChargeFailed" do
    let(:event) { StripeMock.mock_webhook_event('charge.failed') }
    let(:mail) { ActionMailer::Base.deliveries.last }
    let(:member) { create :member }

    subject { StripeEventHelper::ChargeFailed.new.call(event) }

    context "with a Stripe customer ID" do
      before do
        member.update_column(:stripe_customer_id, "beep")
        event.data.object.customer = "beep"
      end

      describe "#call" do
        it "sends an email" do
          expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(mail.to).to include member.email
        end
      end
    end

    context "with no Stripe customer ID" do
      before do
        event.data.object.card.name = "basil@example.com"
        event.data.object.customer = nil
      end

      describe "#call" do
        it "sends an email" do
          expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect(mail.to).to include "basil@example.com"
        end
      end
    end
  end
end
