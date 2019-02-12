class GoogleDriveAccount < ApplicationRecord
    belongs_to :sourcable, :polymorphic => true
end
