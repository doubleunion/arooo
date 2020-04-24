require "spec_helper"
require "stripe_mock"

describe "canceling dues", js: true do
  include UserWithOmniauth
  include AuthHelper

  let(:member) { create_with_omniauth(OmniAuth.config.mock_auth[:github]) }
  let(:stripe_customer_id) { "123abc" }
  let(:plan) {
    OpenStruct.new(
      id: "test_plan",
      amount: 5000,
      currency: "usd",
      interval: "month",
      name: "test plan"
    )
  }
  let(:subscription) {
    OpenStruct.new(
      status: "active",
      plan: plan
    )
  }
  let(:customer) {
    Stripe::Customer.create(
      {
        id: stripe_customer_id,
        email: member.email,
        source: StripeMock.generate_card_token({}),
        subscriptions: [subscription]
      }
    )
  }

  before do
    member.update_attribute(:state, "key_member")
    member.update_attribute(:dues_pledge, 10)
    member.update_attribute(:stripe_customer_id, stripe_customer_id)
    member.update_attribute(:setup_complete, true)

    StripeMock.start
    Stripe.api_key = "coolapikey"
  end

  after do
    StripeMock.stop
  end

  it "a member can cancel their membership" do
    visit root_path
    click_on "Sign in with GitHub"
    expect(page).to have_content "Bookmarks for Members"

    allow(Stripe::Customer).to receive(:retrieve)
      .with(member.stripe_customer_id)
      .and_return(customer)

    click_on "Manage Dues"
    expect(page).to have_content "Manage Your Double Union Dues"
    message = accept_alert {
      click_link "here"
    }
    expect(message).to eq "Are you sure? Clicking yes will cancel your payments, and inform the membership coordinator to remove you from all mailing lists."

    expect(page).to have_content "Your dues have now been canceled"
  end
end
