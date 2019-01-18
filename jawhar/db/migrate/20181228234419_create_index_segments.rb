class CreateIndexSegments < ActiveRecord::Migration[5.1]
  def change
    create_table :index_segments do |t|
      t.references :index, foreign_key: true
      t.references :parent_segment, foreign_key: {to_table: :index_segments}
      t.string :relative_path
      t.timestamp :last_run
      t.timestamp :last_run_started_at
      t.integer :last_duration_seconds
      t.integer :current_status
      t.integer :actual_count
      t.integer :total_count
      t.integer :actual_size
      t.integer :total_size
      t.integer :crawler_pid
      t.timestamps
    end

    add_index :index_segments, ["index_id", "relative_path"], :unique => true  
  end
end


