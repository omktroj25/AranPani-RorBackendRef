class CreateDonorSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :donor_subscriptions do |t|
      t.references :donor,foreign_key: true
      t.references :subscription,foreign_key: true
      t.datetime :last_paid
      t.boolean :last_updated
      t.timestamps
    end
  end
end
