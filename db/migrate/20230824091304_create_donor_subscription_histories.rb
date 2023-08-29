class CreateDonorSubscriptionHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :donor_subscription_histories do |t|
      t.references :donor_subscription,foreign_key: true
      t.references :subscription,foreign_key: true
      t.datetime :last_paid
      t.timestamps
    end
  end
end
