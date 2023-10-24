class UserSerializer < ActiveModel::Serializer
  attributes :id,:phonenumber,:username,:email,:status,:role
  has_many :permissions
end
