class Subscription < ApplicationRecord
    enum plan: [:Monthly,:Quarterly,:HalfYearly,:Yearly]
end
