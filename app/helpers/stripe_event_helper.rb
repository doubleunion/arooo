module StripeEventHelper

  class ChargeSucceeded
    def call(event)
      stripe_customer_id = event.data.object.customer
      user = User.find_by stripe_customer_id: stripe_customer_id
      user.last_stripe_charge_succeeded = event.data.object.created
      user.save
    end
  end

  class ChargeFailed
    def call(event)
    end
  end

end
