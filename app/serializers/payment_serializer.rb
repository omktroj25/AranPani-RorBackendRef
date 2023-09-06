
class PaymentSerializer < ActiveModel::Serializer
  attributes :id,:transaction_id,:amount,:payment_date,:is_one_time_payment,:settled
  has_one :donor,serializer:DonorPaymentSerializer,if: :scope?
  attribute :group_members,if: :family_history?
  attribute :count,if: :family_history?
  def group_members
      object.family_history.donors.reject {|i| i.id==object.family_history.head.id}.map{|i| i.donor_user.name}
  end
  def count
    object.family_history.count
  end
  def family_history?
    object.family_history.present?
  end
  def scope?
    scope
  end
end


