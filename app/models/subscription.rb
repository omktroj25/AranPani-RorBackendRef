class Subscription < ApplicationRecord
    enum plan: [:Monthly,:Quarterly,:HalfYearly,:Yearly]
    has_many :families
    has_many :family_histories
    has_many :donor_subscriptions
    has_many :payments
end
