Rails.configuration.stripe = {
  event_signing_secret: ENV["STRIPE_SIGNING_SECRET"],
  publishable_key: ENV["STRIPE_PUBLISHABLE_KEY"],
  secret_key: ENV["STRIPE_SECRET_KEY"]
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

# You can verify which Stripe API version is in use, or upgrade it, through the
# Stripe developer dashboard: https://dashboard.stripe.com/developers
Stripe.api_version = '2016-02-03'

StripeEvent.signing_secret = Rails.configuration.stripe[:event_signing_secret]

StripeEvent.configure do |events|
  events.subscribe "charge.succeeded", StripeEventHelper::ChargeSucceeded.new
  events.subscribe "charge.failed", StripeEventHelper::ChargeFailed.new
end
