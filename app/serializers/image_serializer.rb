class ImageSerializer < ActiveModel::Serializer
  attributes :id,:image_url,:imageable_id
end
