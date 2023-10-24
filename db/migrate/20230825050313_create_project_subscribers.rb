class CreateProjectSubscribers < ActiveRecord::Migration[7.0]
  def change
    create_table :project_subscribers do |t|
      t.references :donor, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
