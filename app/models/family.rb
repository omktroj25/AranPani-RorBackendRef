class Family < ApplicationRecord
    has_many :donors,dependent: :destroy,autosave:true
    belongs_to :head,class_name: 'Donor',foreign_key: :head_id,autosave:true
    belongs_to :subscription,optional:true
    before_save :update_count
    def update_count
        self.count=self.donors.length
    end
end
