class CreateImages < ActiveRecord::Migration[7.0]
  def change
    create_table :images do |t|
      t.references :imageable,polymorphic: true,null: false
      t.string :image_url
      t.timestamps
    end
  end
end
