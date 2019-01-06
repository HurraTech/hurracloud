class CreateSources < ActiveRecord::Migration[5.1]
  def change
    create_table :sources do |t|
      t.string :name
      t.integer :source_type
      t.string :url
      t.string :unique_id 
      t.integer :capacity, :limit => 8
      t.integer :available, :limit => 8
      t.text :metadata
      t.integer :status
      t.timestamps
    end
  end
end
