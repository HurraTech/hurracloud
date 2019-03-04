class CreateApps < ActiveRecord::Migration[5.1]
  def change
    create_table :apps do |t|
      t.string :app_unique_id
      t.integer :deployment_port
      t.integer :status

      t.timestamps
    end
  end
end
