require "spec_helper"
require "stripe_mock"

describe "canceling dues" do
  let(:member) { create(:key_member, dues_pledge: 10, setup_complete: true, email_for_google: "member@example.com") }
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
    member.update_column(:stripe_customer_id, stripe_customer_id)

    page.set_rack_session(user_id: member.id)

    StripeMock.start
    Stripe.api_key = "coolapikey"
  end

  after do
    StripeMock.stop
  end

  it "a member can cancel their membership" do
    allow(Stripe::Customer).to receive(:retrieve)
      .with(member.stripe_customer_id)
      .and_return(customer)

    visit members_user_dues_path(member)
    expect(page).to have_content "Manage Membership"
    expect(page).to have_content "Cancel Your Membership"

    page.driver.submit :delete, members_user_cancel_path(member), {}

    expect(page).to have_content "Your dues have now been canceled"
  end
end
