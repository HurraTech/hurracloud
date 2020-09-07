Rails.application.config.after_initialize do
  ActiveRecord::Migrator.migrate(Rails.root.join("db/migrate"), nil)
end
