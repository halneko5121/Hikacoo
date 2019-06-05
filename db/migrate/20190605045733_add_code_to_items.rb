class AddCodeToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :isbn_code, :string
    add_column :items, :jan_code, :string
  end
end
