class FamilySerializer < ActiveModel::Serializer
  attributes :id
  has_many :donors
  has_one :head
  has_one :subscription
  def donors
    object.donors.reject{ |i| i.id == object.head.id }
  end
end
