class FamilyHistory < ApplicationRecord
    has_many :donors_family_histories
    has_many :donors,through: :donors_family_histories

    belongs_to :head,class_name: 'Donor',foreign_key: :donor_id
    belongs_to :subscription
    has_many :payments
end
