class Payment < ApplicationRecord
    enum mode: [:online,:offline]
    belongs_to :donor
    belongs_to :area_representative,class_name: 'Donor',foreign_key: :area_representative_id,primary_key: 'area_representative_id',optional:true
    belongs_to :family_history,optional:true
    belongs_to :donor_subscription_history,optional:true
    before_save :add_payment_date
    def add_payment_date
        self.payment_date=Time.now
    end
end
