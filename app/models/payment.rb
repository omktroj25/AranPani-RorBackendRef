class Payment < ApplicationRecord
    enum mode: [:online,:offline]
    belongs_to :donor
    belongs_to :area_representative,class_name: 'Donor',foreign_key: :area_representative_id,primary_key: 'area_representative_id'
    belongs_to :family_history,optional:true
    belongs_to :donor_subscription_history,optional:true
end
