class AddDeletedAtToDonors < ActiveRecord::Migration[7.0]
  def change
    add_column :donors, :deleted_at, :datetime
    add_index :donors, :deleted_at
  end
end
