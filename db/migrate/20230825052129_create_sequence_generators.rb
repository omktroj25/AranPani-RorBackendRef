class CreateSequenceGenerators < ActiveRecord::Migration[7.0]
  def change
    create_table :sequence_generators do |t|
      t.string :model
      t.integer :seq_no

      t.timestamps
    end
  end
end
