class UpdateCountSizeFieldsInIndex < ActiveRecord::Migration[5.1]
  def change
    rename_column :indices, :size, :count
    add_column :indices, :size, :integer
  end
end
