class CreateSources < ActiveRecord::Migration[5.1]
  def change
    create_table :sources do |t|
      t.references :sourcable, polymorphic: true, index: true
      t.string :name
      t.string :unique_id
      t.integer :status
      t.integer :size, limit: 8
      t.integer :used, limit: 8
      t.integer :free, limit: 8
      t.text :metadata

      t.timestamps
    end
  end
end
