class FamilyHistory < ApplicationRecord
    has_many :donors_family_histories
    has_many :donors,through: :donors_family_histories

    belongs_to :head,class_name: 'Donor',foreign_key: :donor_id
    belongs_to :subscription
    has_many :payments,autosave:true
    before_save :update_count
    def update_count
        self.count=self.donors.length
    end
end
