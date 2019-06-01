class RemovePriceFromComparisonItems < ActiveRecord::Migration[5.2]
  def change
    remove_column :comparison_items, :price, :integer
  end
end
