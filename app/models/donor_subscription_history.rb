class DonorSubscriptionHistory < ApplicationRecord
    belongs_to :subscription
    belongs_to :donor_subscription
    has_many :payments
end
