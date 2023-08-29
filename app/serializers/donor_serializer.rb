class DonorSerializer < ActiveModel::Serializer
  attributes :id,:donor_reg_no,:role,:area_representative_id
  has_one :donor_user
end
