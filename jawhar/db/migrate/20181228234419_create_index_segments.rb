class CreateIndexSegments < ActiveRecord::Migration[5.1]
  def change
    create_table :index_segments do |t|
      t.references :index, foreign_key: true
      t.references :parent_segment, foreign_key: {to_table: :index_segments}
      t.string :relative_path
      t.timestamp :last_run
      t.integer :current_status
      t.integer :size
      t.integer :total_size
      t.timestamps
    end

    add_index :index_segments, ["index_id", "relative_path"], :unique => true  
  end
end
