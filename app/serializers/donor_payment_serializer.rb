class DonorPaymentSerializer < ActiveModel::Serializer
  attributes :id,:donor_reg_no,:role,:area_representative
  attribute :donor_user
  def area_representative
    if(object.area_representative.present?)
      {"rep_reg_no":object.area_representative.donor_reg_no,"rep_name":object.area_representative.donor_user.name}
    end
  end
  def donor_user
    ActiveModel::SerializableResource.new(object.donor_user,  each_serializer: DonorUserSerializer)
  end
end
