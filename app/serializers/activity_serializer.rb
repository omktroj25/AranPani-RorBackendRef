class ActivitySerializer < ActiveModel::Serializer
  attributes :id,:description
  has_many :images,serializer:ImageSerializer
end
