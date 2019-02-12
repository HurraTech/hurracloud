class Source < ApplicationRecord
    belongs_to :sourcable, :polymorphic => true
    has_one :index
    serialize :metadata, JSON
    enum status: [ :unmounted, :mounting, :unmounting, :mounted ]

    def as_json(options={})
        super(options.merge!(methods: [:sourcable, :index]))
    end

end
