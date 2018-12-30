require 'json'
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
excludes = [ "*/~*", "*\\.yfull", "*YNAB", "*\\.kdbx", "*\\.kdb", "*\\.y4backup", "*\\.ydiff", "*/\\.DS_Store", "*/\\.*" ]
settings = { excludes: excludes}
settings.to_json
Source.create(name: 'HurraDrive', url: 'file:///mnt/HurraDrive', source_type: :removable_media )