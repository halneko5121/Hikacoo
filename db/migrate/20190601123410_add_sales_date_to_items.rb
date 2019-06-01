class AddSalesDateToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :sales_date, :string
  end
end
