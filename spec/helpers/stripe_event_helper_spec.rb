require "spec_helper"
require "stripe_mock"

describe StripeEventHelper do
  before { StripeMock.start }
  after { StripeMock.stop }

  describe "ChargeSucceeded" do
    let(:event) { StripeMock.mock_webhook_event("charge.succeeded") }
    let(:time) { Time.now }
    let(:member) { create :member }

    subject { StripeEventHelper::ChargeSucceeded.new.call(event) }

    before do
      event.data.object.created = time
      event.data.object.customer = "beep"
      member.update_column(:stripe_customer_id, "beep")
    end

    it "stores the timestamp from Stripe on the user table" do
      expect { subject }.to change { member.reload.last_stripe_charge_succeeded.to_i }.to(time.to_i)
    end
  end

  describe "ChargeFailed" do
    let(:event) { StripeMock.mock_webhook_event("charge.failed") }
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
        event.data.object.source.name = "basil@example.com"
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
