class CreateComparisonItems < ActiveRecord::Migration[5.2]
  def change
    create_table :comparison_items do |t|
      t.string :name
      t.integer :price
      t.text :image_url
      t.text :shop_url

      t.timestamps
    end
  end
end
