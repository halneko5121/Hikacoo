class AddPriceToComparisonItems < ActiveRecord::Migration[5.2]
  def change
    add_column :comparison_items, :price, :string
  end
end
