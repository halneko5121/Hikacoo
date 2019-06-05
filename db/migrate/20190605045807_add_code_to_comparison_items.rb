class AddCodeToComparisonItems < ActiveRecord::Migration[5.2]
  def change
    add_column :comparison_items, :isbn_code, :string
    add_column :comparison_items, :jan_code, :string
  end
end
