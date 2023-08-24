class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.integer :plan
      t.string :no_of_months
      t.integer :amount
      t.boolean :status
      t.timestamps
    end
  end
end
