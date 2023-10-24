class CreateActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :activities do |t|
      t.references :project, null: false, foreign_key: true
      t.string :description

      t.timestamps
    end
  end
end
