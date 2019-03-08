class AppCommand < ApplicationRecord
    belongs_to :app
    serialize :environment, JSON
    enum status: [ :pending, :executing, :completed, :failed ]

    # def command=(val)
    #   write_attribute(:command, val.sub("$", "\\$"))
    # end
      
  end
  