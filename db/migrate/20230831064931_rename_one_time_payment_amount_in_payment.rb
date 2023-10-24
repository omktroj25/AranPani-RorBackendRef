class RenameOneTimePaymentAmountInPayment < ActiveRecord::Migration[7.0]
  def change
    rename_column :payments, :one_time_payment_amount, :amount
  end
end
