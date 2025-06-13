module StripeEventHelper
  class ChargeSucceeded
    def call(event)
      stripe_customer_id = event.data.object.customer
      user = User.find_by stripe_customer_id: stripe_customer_id
      user.last_stripe_charge_succeeded = Time.at(event.data.object.created).to_datetime
      user.save!
    end
  end

  class ChargeFailed
    def call(event)
      email = if event.data.object.customer.present?
        User.find_by_stripe_customer_id(event.data.object.customer).email
      else
        event.data.object.source.name
      end
      DuesMailer.failed(email).deliver_now
    end
  end
end
