require 'spec_helper'

describe Members::UsersController do
  include AuthHelper

  let(:someone_cool) { create(:member) }

  describe 'GET index' do
    subject { get :index }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it 'redirects if not logged in' do
      subject
      response.should redirect_to :root
    end
  end

  describe 'GET show' do
    subject { get :show, id: someone_cool.id }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it 'redirects if not logged in' do
      subject
      response.should redirect_to :root
    end
  end

  describe 'GET edit' do
    subject { get :edit, id: someone_cool.id }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it 'redirects if not logged in' do
      subject
      response.should redirect_to :root
    end
  end

  describe 'POST update' do
    subject { post :update, id: someone_cool.id, user: {id: someone_cool.id} }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it 'redirects if not logged in' do
      subject
      response.should redirect_to :root
    end

    describe "updating stuff" do
      context "when logged in" do
        it 'updates name and email' do
          user = login_as(:member, name: 'Foo Bar', email: 'someone@foo.bar')

          post :update, id: user.id, user: {
            name: 'FooBar TooBar',
            email: 'someone2@foo.bar',
            profile_attributes: { skills: 'writing awesome tests' }
          }

          response.should render_template :edit

          user.name.should eq('FooBar TooBar')
          user.email.should eq('someone2@foo.bar')
          user.profile.skills.should eq('writing awesome tests')
        end
      end

      context "when not logged in as particular user" do
        it "updates your own info instead of theirs" do
          member = login_as(:member)

          post :update, id: someone_cool.id, user: { name: 'Little Bobby Tables Was Here' }

          expect(someone_cool.name).to eq(someone_cool.reload.name)
          expect(member.name).to eq("Little Bobby Tables Was Here")
        end
      end
    end
  end

  describe 'GET setup' do
    subject { get :setup, user_id: someone_cool.id }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it 'redirects if not logged in' do
      subject
      response.should redirect_to :root
    end
  end

  describe 'PATCH finalize' do
    subject {  patch :finalize, user_id: someone_cool.id, user: {dues_pledge: 25} }

    it_should_behave_like "deny non-members", [:visitor, :applicant]

    it 'updates Google email and dues pledge if logged in' do
      user = login_as(:member, name: 'Foo Bar', email: 'someone@foo.bar')

      patch :finalize, user_id: user.id, user: {
        dues_pledge: 25,
        email_for_google: 'googly-eyes@example.com'
      }

      response.should render_template "setup"

      user.dues_pledge.should eq(25)
      user.email_for_google.should eq('googly-eyes@example.com')
    end
  end

  describe 'GET dues' do
    subject { get :dues, user_id: someone_cool.id }

    it_should_behave_like "deny non-members", [:visitor, :applicant]
    it_should_behave_like "allow members", [:member, :voting_member]

    it 'redirects if not logged in' do
      subject
      response.should redirect_to :root
    end
  end

  describe 'POST submit_dues_to_stripe' do
    before do
      StripeMock.start
      Stripe::Plan.create(:id => "test_plan",
                          :amount => 5000,
                          :currency => 'usd',
                          :interval => 'month',
                          :name => "test plan")
    end

    after do
      StripeMock.stop
    end

    let(:token) { StripeMock.generate_card_token({}) }

    let(:params) do
      {
        user_id: user.id,
        email: 'user@example.com',
        plan: "test_plan",
        token: token
      }
    end

    let!(:user) { login_as(:member, name: 'Foo Bar', email: 'someone@foo.bar') }

    subject(:post_dues) { post :submit_dues_to_stripe, params }

    context "when the user already has a Stripe ID" do
      before do
        customer = Stripe::Customer.create({
                                               email: 'user@example.com',
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
end
