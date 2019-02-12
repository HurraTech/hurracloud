class CreateDrivePartitions < ActiveRecord::Migration[5.1]
  def change
    create_table :drive_partitions do |t|
      t.references :drive, foreign_key: true
      t.integer :partitionNumber
      t.string :deviceFile
      t.string :filesystem

      t.timestamps
    end
  end
end
