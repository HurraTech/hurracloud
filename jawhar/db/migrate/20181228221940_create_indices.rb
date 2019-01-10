class CreateIndices < ActiveRecord::Migration[5.1]
  
  def change
    create_table :indices do |t|
      t.references :device_partition, foreign_key: true
      t.string :settings
      t.integer :count
      t.integer :size
      t.timestamps
    end
  end
end
