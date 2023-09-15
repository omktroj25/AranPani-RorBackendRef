class Donor < ApplicationRecord
    acts_as_paranoid
    enum role: [:group_head,:group_member,:individual_donor]
    before_update :modify_role,:modify_is_area_representative
    has_one :donor_user,dependent: :destroy
    belongs_to :family,foreign_key: :family_id,optional:true,autosave:true

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

    scope :representative_search,->(params){joins(:donor_user).where(["name LIKE ? or email LIKE ? or phonenumber LIKE ? or donor_reg_no LIKE ?","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%"]).where("is_area_representative = ?",true)}
    scope :search,->(params){joins(:donor_user).where(["name LIKE ? or email LIKE ? or phonenumber LIKE ? or donor_reg_no LIKE ?","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%"])}
    private 
    def modify_role
        if will_save_change_to_role?
            if(self.role=="individual_donor")
                @family=self.family
                @family.last_updated=false
                @family.save!
                self.family_id=nil
                self.role=Donor.roles[:individual_donor]
            elsif(self.role=="group_head"  && self.family_id.present?)
                @old_group_head=self.family.head
                @old_group_head.role=Donor.roles[:group_member]
                @old_group_head.save!
                @family=self.family
                @family.head=self
                @family.last_updated=false
                @family.save!
                self.role=Donor.roles[:group_head]
            end
        end
    end
    def modify_is_area_representative
        if will_save_change_to_is_area_representative?
            if self.is_area_representative && self.role=="group_member"
                self.errors.add(:is_area_representative, "Group member can't be promoted")
                throw :abort
            elsif self.is_area_representative
                self.area_representative_id=self.id
                self.is_area_representative=true
                if self.group_head?
                    @family=self.family
                    @family.donors.update_all(area_representative_id:self.id)
                end
            end
        end
    end

end