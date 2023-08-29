class AddLastUpdatedToFamily < ActiveRecord::Migration[7.0]
  def change
    add_column :families,:last_updated,:boolean
  end
end
