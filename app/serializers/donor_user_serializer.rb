class DonorUserSerializer < ActiveModel::Serializer
  attributes :id,:name,:age,:phonenumber,:email,:guardian_name,:country,:pincode,:address,:gender,:id_card,:id_card_value,:pan
end
