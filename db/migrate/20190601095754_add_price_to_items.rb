class AddPriceToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :price, :string
  end
end
