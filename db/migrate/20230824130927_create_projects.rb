class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :reg_no
      t.string :temple_name
      t.string :incharge_name
      t.string :phonenumber
      t.string :location
      t.integer :status
      t.datetime :start_date
      t.datetime :end_date
      t.integer :estimated_amount
      t.integer :expensed_amount
      t.timestamps
    end
  end
end
