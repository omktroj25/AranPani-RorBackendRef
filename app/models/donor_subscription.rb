class DonorSubscription < ApplicationRecord
    belongs_to :donor
    belongs_to :subscription
end
