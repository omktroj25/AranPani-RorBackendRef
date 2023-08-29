class CreateDonorUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :donor_users do |t|
      t.string :name
      t.integer :age
      t.string :phonenumber,unique: true
      t.string :email
      t.string :guardian_name
      t.string :country
      t.string :pincode
      t.string :address
      t.integer :gender
      t.string :id_card
      t.string :id_card_value
      t.boolean :is_onboarded
      t.string :pan
      t.references :donor,foreign_key: true
      t.timestamps
    end
  end
end
