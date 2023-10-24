class CreateFamilies < ActiveRecord::Migration[7.0]
  def change
    create_table :families do |t|
      t.datetime :last_paid
      t.integer :count
      t.references :subscriptions,foreign_key:true
      t.references :head,foreign_key:{to_table: :donors}
      t.timestamps
    end
  end
end
