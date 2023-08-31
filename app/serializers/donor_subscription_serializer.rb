class DonorSubscriptionSerializer < ActiveModel::Serializer
  attributes :id,:last_paid,:last_updated
  belongs_to :subscription
end
