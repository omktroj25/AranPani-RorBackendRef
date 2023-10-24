class AddColumnToPayment < ActiveRecord::Migration[7.0]
  def change
    add_reference :payments,:subscription,index:true
    remove_reference :payments,:donor_subscription_history
  end
end
