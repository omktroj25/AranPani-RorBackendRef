class CreateFamilyHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :family_histories do |t|
        t.integer :count
        t.datetime :last_paid
        t.references :donor,foreign_key: true
        t.references :subscription,foreign_key: true
      t.timestamps
    end
  end
end
