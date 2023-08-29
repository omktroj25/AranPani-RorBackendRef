class CreateDonorsFamilyHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :donors_family_histories do |t|
      t.references :donor, null: false, foreign_key: true
      t.references :family_history, null: false, foreign_key: true

      t.timestamps
    end
  end
end
