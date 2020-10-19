require "spec_helper"

describe Members::DuesController do
  include AuthHelper

  let(:member) { create(:member) }

  describe "GET show" do
    subject { get :show, params: { user_id: member.id } }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it "redirects if not logged in" do
      subject
      expect(response).to redirect_to :root
    end

    context "when a member has an associated Stripe account without a subscription" do
      let(:current_user) do
         login_as(
           :member,
           name: "Foo Bar",
           email: "someone@example.com",
           stripe_customer_id: 'stripe-user-id-abc123'
         )
      end

      before do
        StripeMock.start

        Stripe::Customer.create(
          subscriptions: [],
          id: current_user.stripe_customer_id
        )
      end

      after do
        StripeMock.stop
      end

      it "renders ok" do
        subject

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "DELETE cancel" do
    let!(:user) { login_as(:member, name: "Foo Bar", email: "someone@example.com") }

    let(:params) do
      {
        user_id: user.id
      }
    end

    subject(:cancel_dues) { delete :cancel, params: params }

    context "when the user does not have a Stripe ID" do
      it "sets the flash and redirects to the manage dues page" do
        expect(subject).to redirect_to members_user_dues_path(user)
        expect(flash[:notice]).to include "You don't have an active membership dues subscription"
      end
    end

    context "when the user already has a Stripe ID" do
      before do
        StripeMock.start
        # TODO: remove api_key setting when this issue is fixed:
        # https://github.com/rebelidealist/stripe-ruby-mock/issues/209
        Stripe.api_key = "coolapikey"
        Stripe::Plan.create(id: "test_plan",
                            amount: 5000,
                            currency: "usd",
                            interval: "month",
                            product: "test product",
                            name: "test plan")

        # Must set referrer so that DuesController#redirect_target works
        request.env["HTTP_REFERER"] = "http://example.com/members/users/x/dues"

        user.update_column(:stripe_customer_id, customer.id)
      end

      after do
        StripeMock.stop
      end

      let(:customer) do
        Stripe::Customer.create({
          email: "user@example.com",
          source: StripeMock.generate_card_token({})
        })
      end

      let(:active_subscription) do
        customer.subscriptions.create({plan: "test_plan"})
      end

      it "should cancel their active subscription" do
        canceled_subscription_id = active_subscription.id

        cancel_dues

        expect { customer.subscriptions.retrieve(canceled_subscription_id) }.to raise_error(Stripe::InvalidRequestError)
        expect(subject).to redirect_to members_user_dues_path(user)
      end

      it "emails the membership coordinator" do
        expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end

  describe "POST update" do
    before do
      StripeMock.start
      # TODO: remove api_key setting when this issue is fixed:
      # https://github.com/rebelidealist/stripe-ruby-mock/issues/209
      Stripe.api_key = "coolapikey"
      Stripe::Plan.create(id: "test_plan",
                          amount: 5000,
                          currency: "usd",
                          interval: "month",
                          product: "test product",
                          name: "test plan")

      # Must set referrer so that DuesController#redirect_target works
      request.env["HTTP_REFERER"] = "http://example.com/members/users/x/dues"
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

    subject(:post_dues) { post :update, params: params }

    context "when the user is coming from the account setup page" do
      # Must set referrer so that DuesController#redirect_target works
      before { request.env["HTTP_REFERER"] = "http://example.com/members/users/x/setup" }

      it "redirects to the membership setup page" do
        expect(subject).to redirect_to members_user_setup_path(user)
      end
    end

    context "when the user already has a Stripe ID" do
      let(:customer) do
        Stripe::Customer.create({
          email: "user@example.com",
          source: StripeMock.generate_card_token({})
        })
      end

      before do
        user.update_column(:stripe_customer_id, customer.id)
      end

      context "previous subscription has been canceled" do
        it "creates new subscription with plan" do
          post_dues
          subscription = Stripe::Customer.retrieve(user.stripe_customer_id).subscriptions.first
          expect(subscription.plan.id).to eq("test_plan")
        end

        it "redirects to the manage dues page" do
          expect(subject).to redirect_to members_user_dues_path(user)
        end
      end

      context "has a prior payment source" do
        before { Stripe::Customer.retrieve(user.stripe_customer_id) }

        let!(:previous_default_source) { Stripe::Customer.retrieve(user.stripe_customer_id).sources.first }

        it "updates their card" do
          post_dues
          customer = Stripe::Customer.retrieve(user.stripe_customer_id)
          expect(customer.default_source).to_not eq(previous_default_source)
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
    let(:params) { {"user_id" => member.id, "reason" => "Lemurs are pretty great animals."} }

    subject { post :scholarship_request, params: params }

    context "logged in as a member" do
      before { login_as member }

      it "sends an email" do
        expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
        expect(ActionMailer::Base.deliveries.last.to).to eq(["scholarship@doubleunion.org", member.email])
        expect(ActionMailer::Base.deliveries.last.body).to include "Lemurs are pretty great"
      end
    end
  end
end
