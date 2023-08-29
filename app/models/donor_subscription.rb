class DonorSubscription < ApplicationRecord
    belongs_to :donor
    belongs_to :subscription
    has_many :donor_subscription_histories
end
