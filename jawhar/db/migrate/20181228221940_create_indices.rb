class CreateIndices < ActiveRecord::Migration[5.1]
  def change
    create_table :indices do |t|
      t.string :name
      t.integer :type
      t.string :settings

      t.timestamps
    end
  end
end
