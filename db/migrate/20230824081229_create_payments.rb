class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.integer :mode
      t.boolean :is_one_time_payment
      t.integer :one_time_payment_amount
      t.datetime :payment_date
      t.string :transaction_id
      t.references :donor,foreign_key:true
      t.references :area_representative,foreign_key: { to_table: :donors }
      t.references :family_history,foreign_key:true,null:true
      t.references :donor_subscription_history,foreign_key:true,null:true
      t.boolean :settled

      t.timestamps
    end
  end
end
