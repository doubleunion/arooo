class RemoveLimitFromStripeCustomerId < ActiveRecord::Migration
  def up
    change_column :users, :stripe_customer_id, :string, limit: nil
  end

  def down
    change_column :users, :stripe_customer_id, :string, limit: 255
  end
end
