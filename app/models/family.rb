class Family < ApplicationRecord
    has_many :donors,dependent: :destroy,autosave:true
    belongs_to :head,class_name: 'Donor',foreign_key: :head_id
    belongs_to :subscription,optional:true
end
