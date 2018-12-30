class CreateIndices < ActiveRecord::Migration[5.1]
  
  def change
    create_table :indices do |t|
      t.references :source, foreign_key: true
      t.string :name
      t.string :settings
      t.integer :size
      t.timestamps
    end
  end
end
