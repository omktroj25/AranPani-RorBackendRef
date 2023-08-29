class CreateDonors < ActiveRecord::Migration[7.0]
  def change
    create_table :donors do |t|
      t.string :donor_reg_no
      t.boolean :is_area_representative
      t.integer :role
      t.boolean :status
      t.references :family,foreign_key: true,null:true
      t.references :area_representative, foreign_key: { to_table: :donors }
      t.timestamps
    end
  end
end
