class Donor < ApplicationRecord
    acts_as_paranoid
    enum role: [:group_head,:group_member,:individual_donor]
    has_one :donor_user,dependent: :destroy
    belongs_to :family,foreign_key: :family_id,optional:true,autosave:true
    # has_one :head,class_name: 'Family',foreign_key: :head_id
    # has_one :family_history
    has_one :donor_subscription,autosave:true
    has_many :payments,foreign_key: :area_representative_id,autosave:true
    has_many :payments,foreign_key: :donor_id,autosave:true

    has_many :donors_family_histories
    has_many :family_histories,through: :donors_family_histories
# self-join
    has_many :donators,class_name: 'Donor',foreign_key: :area_representative_id,autosave:true
    belongs_to :area_representative,class_name: 'Donor', optional:true
# Project subscribers

    has_many :project_subscribers
    has_many :projects,through: :project_subscribers

    accepts_nested_attributes_for :donor_user,:donor_subscription
    
end
