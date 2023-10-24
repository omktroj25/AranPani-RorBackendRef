class DonorSerializer < ActiveModel::Serializer
  attributes :id,:donor_reg_no,:role,:area_representative_id,:status,:is_area_representative
  has_one :donor_user
  has_one :donor_subscription
  attribute :group_head,if: :has_group?
  def donor_subscription
    object.donor_subscription if object.donor_subscription.present?
  end
  def has_group?
    object.family.present?
  end
  def group_head
    object.family.head
  end
end
