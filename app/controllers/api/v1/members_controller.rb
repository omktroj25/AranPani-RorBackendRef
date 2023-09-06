class Api::V1::MembersController < ApplicationController
    before_action { authorize("donors") }
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
        if @group_head.individual_donor? && !@group_head.family_id.present?
            @family=Family.new(subscription_id:@group_head.donor_subscription.subscription.id)
            @group_head.role=Donor.roles[:group_head]
            @group_head.save
            @family.head=@group_head
            @family.donors.push(@group_head)
            @family.save
        end
        if(params[:id].present?)
            @donor=Donor.find(params[:id])
            @family=@group_head.family
            if @donor.individual_donor?
                @donor.role=Donor.roles[:group_member]
                @family.donors.push(@donor)
            elsif @donor.group_member?
                @donor.family_id=nil
                @family.donors.push(@donor)
            else
                for i in @donor.family.donors
                    i.family_id=nil
                    @family.donors.push(i)
                end
                @donor.family_id=nil
                @donor.role=Donor.roles[:group_member]
                @family.donors.push(@donor)
            end
        else
            @sequence_generator=SequenceGenerator.find_by(model:"donor")
            seq=@sequence_generator.seq_no
            @donor_user=DonorUser.new(phonenumber:params[:phonenumber],name:params[:name],is_onboarded:false)
            @donor=Donor.new(donor_user:@donor_user,status:true,is_area_representative:false,role:Donor.roles[:group_member],area_representative:@group_head.area_representative)
            @donor.donor_reg_no="DON"+@sequence_generator.seq_no.to_s
            @sequence_generator.update(seq_no:seq+1)
            @donor.save
            @family=Family.find(@group_head.family.id)
            @family.donors.push(@donor)
        end
        @family.last_updated=false
        if @family.save
            render json: @family,include:['donors.donor_user','head','subscription'],status: :ok
        else
            render json: @family.errors,status: :unprocessable_entity
        end
    end
    def destroy
        @donor=Donor.find(params[:id])
        if @donor.group_member? && !@donor.donor_user.is_onboarded
            @family=@donor.family
            @family.last_updated=false
            @family.save
            @donor.destroy
            render json:{status:"success"},status: :ok
        else
            render json:{status:"Only group member can be deleted"},status: :unprocessable_entity
        end
    end
    def promote_donor
        @donor=Donor.find(params[:id])
        @donor.role=Donor.roles[:individual_donor]
        @family=@donor.family
        @family.last_updated=false
        @family.save
        @donor.family_id=nil
        if @donor.save
            render json: @donor,status: :ok
        else
            render json: @donor.errors,status: :unprocessable_entity
        end

    end
    def promote_head
        @new_group_head=Donor.find(params[:id])
        @past_group_head=Donor.find(params[:donor_id])
        if @new_group_head.family_id == @past_group_head.family_id 
            @past_group_head.role=Donor.roles[:group_member]
            @past_group_head.save
            @new_group_head.role=Donor.roles[:group_head]
            @family=@new_group_head.family
            @family.head=@new_group_head
            @family.last_updated=false
            if @family.save
                render json: @family,status: :ok
            else
                render json: @family.errors,status: :unprocessable_entity
            end
        end
    end
end
