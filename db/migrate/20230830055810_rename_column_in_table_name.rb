class RenameColumnInTableName < ActiveRecord::Migration[7.0]
  def change
    rename_column :families, :subscriptions_id, :subscription_id
  end
end
