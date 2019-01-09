class CreateDevicePartitions < ActiveRecord::Migration[5.1]
  def change
    create_table :device_partitions do |t|
      t.references :source, foreign_key: true
      t.string :uuid
      t.integer :partitionNumber
      t.string :deviceFile
      t.string :label
      t.boolean :mounted
      t.string :filesystem
      t.integer :size
      t.integer :available
      t.text :raw

      t.timestamps
    end
  end
end
