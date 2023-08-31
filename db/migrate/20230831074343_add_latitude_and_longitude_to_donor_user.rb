class AddLatitudeAndLongitudeToDonorUser < ActiveRecord::Migration[7.0]
  def change
    add_column :donor_users,:latitude,:float
    add_column :donor_users,:longitude,:float
  end
end
