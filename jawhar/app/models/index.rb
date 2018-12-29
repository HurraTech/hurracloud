class Index < ApplicationRecord
    belongs_to :source

    before_create do |index|
        puts "Creating index for source #{source.name}"
    end
end
