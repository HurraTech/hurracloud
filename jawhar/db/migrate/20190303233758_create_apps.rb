class CreateApps < ActiveRecord::Migration[5.1]
  def change
    create_table :apps do |t|
      t.string :app_unique_id
      t.string :name
      t.string :version      
      t.string :description
      t.integer :deployment_port
      t.integer :status
      t.text :iconSvg
      t.text :initCommands
      t.timestamps
    end
  end
end
