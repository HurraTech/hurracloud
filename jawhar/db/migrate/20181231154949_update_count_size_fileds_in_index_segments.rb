class UpdateCountSizeFiledsInIndexSegments < ActiveRecord::Migration[5.1]
  def change
    rename_column :index_segments, :size, :actual_count
    rename_column :index_segments, :total_size, :total_count
    add_column :index_segments, :actual_size, :integer
    add_column :index_segments, :total_size, :integer
  end
end
