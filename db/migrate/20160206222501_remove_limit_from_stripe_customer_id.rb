class RemoveLimitFromStripeCustomerId < ActiveRecord::Migration[4.2]
  def up
    change_column :users, :stripe_customer_id, :string, limit: nil
  end

  def down
    change_column :users, :stripe_customer_id, :string, limit: 255
  end
end
