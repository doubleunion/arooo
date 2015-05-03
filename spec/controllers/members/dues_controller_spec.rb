require "spec_helper"

describe Members::DuesController do
  include AuthHelper

  let(:member) { create(:member) }

  describe "GET show" do
    subject { get :show, user_id: member.id }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it "redirects if not logged in" do
      subject
      response.should redirect_to :root
    end
  end

  describe "POST update" do
    before do
      StripeMock.start
      Stripe::Plan.create(:id => "test_plan",
        :amount => 5000,
        :currency => "usd",
        :interval => "month",
        :name => "test plan")
    end

    after do
      StripeMock.stop
    end

    let(:token) { StripeMock.generate_card_token({}) }

    let(:params) do
      {
        user_id: user.id,
        email: "user@example.com",
        plan: "test_plan",
        token: token
      }
    end

    let!(:user) { login_as(:member, name: "Foo Bar", email: "someone@foo.bar") }

    subject(:post_dues) { post :update, params }

    context "when the user already has a Stripe ID" do
      before do
        customer = Stripe::Customer.create({
            email: "user@example.com",
            card: StripeMock.generate_card_token({})
          })
        user.update_column(:stripe_customer_id, customer.id)
      end

      context "previous subscription has been canceled" do
        it "creates new subscription with plan" do
          post_dues
          subscription = Stripe::Customer.retrieve(user.stripe_customer_id).subscriptions.first
          expect(subscription.plan.id).to eq("test_plan")
        end
      end

      context "has active subscription" do
        before do
          Stripe::Customer.retrieve(user.stripe_customer_id).subscriptions.create({:plan => "test_plan"})
        end

        let!(:previous_default_card) { Stripe::Customer.retrieve(user.stripe_customer_id).cards.first }

        it "updates their card" do
          post_dues
          customer = Stripe::Customer.retrieve(user.stripe_customer_id)
          expect(customer.default_card).to_not eq(previous_default_card)
          subscription = customer.subscriptions.first
          expect(subscription.plan.id).to eq("test_plan")
        end
      end
    end

    context "when the user doesn't have a Stripe ID" do

      it "updates their stripe customer ID in the database" do
        post_dues
        expect(user.stripe_customer_id).to be_present
        subscription = Stripe::Customer.retrieve(user.stripe_customer_id).subscriptions.first
        expect(subscription.plan.id).to eq("test_plan")
      end
    end
  end

  describe "POST scholarship_request" do
    let(:params) { { "user_id" => member.id, "reason" => "Lemurs are pretty great animals." } }

    subject { post :scholarship_request, params }

    context "logged in as a member" do
      before { login_as member }

      it "sends an email" do
        expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(ActionMailer::Base.deliveries.last.to).to eq(["scholarship@doubleunion.org"])
        expect(ActionMailer::Base.deliveries.last.body).to include "Lemurs are pretty great"
      end
    end
  end
end
