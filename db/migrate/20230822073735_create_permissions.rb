class CreatePermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :permissions do |t|
      t.string :scope
      t.references :user,foreign_key:true
      t.timestamps
    end
  end
end
