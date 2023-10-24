class Api::V1::MembersController < ApplicationController
    before_action { authorize("donors") }
    before_action :find_donor,only:[:destroy,:promote_donor,:update]
    include SequenceGeneratorService
    def index
        @donor=Donor.find(params[:donor_id])
        if @donor.group_head?
          render json: @donor.family,include:['donors'],status: :ok
        else
            render json:{message:"Donor is not a group head"},status: :unprocessable_entity
        end  
    end
    def create
        @group_head=Donor.find(params[:donor_id])
        begin
            ActiveRecord::Base.transaction do
                if @group_head.individual_donor? && !@group_head.family_id.present?
                    @family=Family.new(subscription_id:@group_head.donor_subscription.subscription.id)
                    @group_head.role=Donor.roles[:group_head]
                    @group_head.save!
                    @family.head=@group_head
                    @family.donors.push(@group_head)
                    @family.save!
                end
                if(params[:id].present?)
                    find_donor
                    @family=@group_head.family
                    if @donor.group_head?
                        @donor.family.donors.update_all(family_id:@family.id)
                    end
                    @donor.role=Donor.roles[:group_member]
                    @family.donors.push(@donor)
                else
                    @donor_user=DonorUser.new(phonenumber:params[:phonenumber],name:params[:name],is_onboarded:false)
                    @donor=Donor.new(donor_user:@donor_user,status:true,is_area_representative:false,role:Donor.roles[:group_member],area_representative:@group_head.area_representative)
                    @donor.donor_reg_no="DON"+sequence_generator('donor').to_s
                    @donor.save!
                    @family=Family.find(@group_head.family.id)
                    @family.donors.push(@donor)
                end
                @family.last_updated=false
                @family.save!
                render json: @family,include:['donors.donor_user','head','subscription'],status: :ok
            end
        rescue Exception=>e
            render json:{status:e.message},status: :ok
        end
    end
    def destroy
        if @donor.group_member? && !@donor.donor_user.is_onboarded
            @family=@donor.family
            @family.last_updated=false
            ActiveRecord::Base.transaction do
                @family.save!
                @donor.destroy!
                render json:{status:"success"},status: :ok
            end
        else
            render json:{status:"Only group member can be deleted"},status: :unprocessable_entity
        end
    end
    def update
        if @donor.update("role":params[:role])
            if params[:role]=="group_head"
                render json:@donor.family,status: :ok
            else
                render json:@donor,status: :ok
            end
        else
            render json:@donor.errors,status: :ok
        end
    end
    private 
    def find_donor
        @donor=Donor.find(params[:id])
    end
end
