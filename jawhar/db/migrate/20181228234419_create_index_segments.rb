class CreateIndexSegments < ActiveRecord::Migration[5.1]
  def change
    create_table :index_segments do |t|
      t.references :index, foreign_key: true
      t.string :relative_path
      t.timestamp :last_run
      t.integer :current_status
      t.integer :last_count

      t.timestamps
    end
  end
end
