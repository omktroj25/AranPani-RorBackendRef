class DropDonorSubscriptionHistory < ActiveRecord::Migration[7.0]
  def change
    drop_table :donor_subscription_histories
  end
end
