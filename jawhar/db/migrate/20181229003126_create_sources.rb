class CreateSources < ActiveRecord::Migration[5.1]
  def change
    create_table :sources do |t|
      t.string :name
      t.integer :source_type
      t.string :url
      t.text :metadata

      t.timestamps
    end
  end
end
