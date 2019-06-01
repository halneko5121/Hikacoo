class AddSalesDateToComparisonItems < ActiveRecord::Migration[5.2]
  def change
    add_column :comparison_items, :sales_date, :string
  end
end
