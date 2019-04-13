class CreateAppCommands < ActiveRecord::Migration[5.1]
  def change
    create_table :app_commands do |t|
      t.string :command
      t.string :container
      t.text :environment
      t.integer :status
      t.text :output
      t.references :app, foreign_key: true

      t.timestamps
    end
  end
end
