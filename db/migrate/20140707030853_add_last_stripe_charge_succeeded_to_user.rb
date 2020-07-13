class AddLastStripeChargeSucceededToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :last_stripe_charge_succeeded, :datetime
  end
end
