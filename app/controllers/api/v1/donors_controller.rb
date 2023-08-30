class Api::V1::DonorsController < ApplicationController
    before_action { authorize("donors") }
    def index
        render json: search,status: :ok
    end
    def create
        @donor=Donor.new(donor_params)
        @sequence_generator=SequenceGenerator.find_by(model:"donor")
        seq=@sequence_generator.seq_no
        @donor.donor_reg_no="DON"+@sequence_generator.seq_no.to_s
        @sequence_generator.update(seq_no:seq+1)
        @donor.is_area_representative=false
        @donor.role=Donor.roles[:individual_donor]
        # p params[:subscription_id]
        # @donor.donor_subscription=DonorSubscription.new(subscription:Subscription.find(params[:subscription_id]),last_updated:false)
        if @donor.save
            render json: @donor,status: :ok
        else
            render json: @donor.errors,status: :unprocessable_entity
        end
    end
    def update
        @donor=Donor.find(params[:id])
        p update_donor_params
        if @donor.update(update_donor_params)
            render json: @donor,status: :ok
        else
            render json: @donor.errors,status: :unprocessable_entity
        end
    end
    def subscription
        @donor=Donor.find(params[:id])
        if(@donor.family_id != null && @donor.group_head?)
            @donor.family.subscription=Subscription.find(params[:subscription_id])
            @donor.family.last_updated=false
        elsif(@donor.subscription_id !=null && @donor.individual_donor?)
            @donor.donor_subscription.subscription=Subscription.find(params[:subscription_id])
            @donor.donor_subscription.last_updated=false
        else
            render json: {status:"Update the subscription through your group head"},status: :unprocessable_entity
        end
        if @donor.save
            render json: @donor,status: :ok
        else
            render json: @donor.errors,status: :unprocessable_entity
        end
    end
    def deactivate
        @donor=Donor.find(params[:id])
        @donor.status=params[:status]
        if @donor.save
            render json: @donor,status: :ok
        else
            render json: @donor.errors,status: :unprocessable_entity
        end
    end
    def find
        @donor_user=DonorUser.find_by(phonenumber:params[:phonenumber])
        render json: @donor_user.donor,status: :ok
    end
    def promote_rep
        @donor=Donor.find(params[:id])
        if @donor.group_head?
            @donor.area_representative_id=@donor.id
            @donor.is_area_representative=true
            @family=@donor.family
            lt=[]
            for i in @family.donors
                i.area_representative=@donor
                lt.push(i)
            end
            @family.donors=lt
            @family.save
        else
            @donor.area_representative_id=@donor.id
            @donor.is_area_representative=true
        end
        if @donor.save
            render json: @donor,status: :ok
        else
            render json: @donor.errors,status: :unprocessable_entity
        end
    end
    private
    def donor_params
        params.require(:donor).permit(:area_representative_id,:status,donor_user_attributes:[:name,:age,:phonenumber,:email,:guardian_name,:country,:pincode,:address,:gender,:id_card,:id_card_value,:is_onboarded,:pan],donor_subscription_attributes:[:subscription_id,:last_updated])
    end
    def update_donor_params
        params.require(:donor).permit(:id,:donor_reg_no,:role,:area_representative_id,:status,donor_user_attributes:[:id,:name,:age,:phonenumber,:email,:guardian_name,:country,:pincode,:address,:gender,:id_card,:id_card_value,:is_onboarded,:pan])
    end
    def search
        Donor.joins(:donor_user).where(["name LIKE ? or email LIKE ? or phonenumber LIKE ? or donor_reg_no LIKE ?","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%"]).paginate(page:params[:page],per_page:params[:limit])
    end
end
