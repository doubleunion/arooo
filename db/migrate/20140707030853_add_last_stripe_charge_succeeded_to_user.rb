class AddLastStripeChargeSucceededToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_stripe_charge_succeeded, :datetime
  end
end
