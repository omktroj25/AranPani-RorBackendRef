class Api::V1::DonorsController < ApplicationController
    before_action { authorize("donors") }
    before_action :find_donor,only:[:update,:promote_rep,:show]
    before_action :validates_update,only:[:update]
    include SequenceGeneratorService
    def index
        render json: Donor.search(params).paginate(page:params[:page],per_page:params[:limit]),status: :ok
    end
    def create
        @donor=Donor.new(donor_params)
        if !Subscription.find(@donor.donor_subscription.subscription.id).status
            return render json:{status:false,message:"Subscription was deactivated by the admin"},status: :ok
        end
        begin
            ActiveRecord::Base.transaction do
                @donor.donor_reg_no="DON"+sequence_generator('donor').to_s
                @donor.is_area_representative=false
                @donor.role=Donor.roles[:individual_donor]
                @donor.save!
                render json:@donor,status: :ok
            end
        rescue Exception => e
            render json:{status:e.message},status: :ok
            Rails.logger.error e
        end
    end
    def update
            if @donor.update(update_donor_params)
                render json: @donor,status: :ok
            else
                render json: @donor.errors,status: :unprocessable_entity
            end
    end
    def show
        render json: @donor,status: :ok
    end
    def demote_rep
        @old_representative=Donor.find_by(id:params[:id],is_area_representative:true)
        @new_representative=Donor.find_by(id:params[:representative_id],is_area_representative:true)
        if @old_representative.present? 
            begin
                ActiveRecord::Base.transaction do
                    @old_representative.donators.update_all(area_representative_id:@new_representative.id)
                    @old_representative.update!(is_area_representative:false)
                    @new_representative.save!
                    render json: @new_representative,serializer:RepresentativeSerializer,scope:true,include:['donators.donor_user','donor_user','donor_subscription'],status: :ok
                end
            rescue Exception=>e
                render json:{status:e.message},status: :ok
            end         
        else
            render json:{status:false,message:"Current donor is not area representative"},status: :ok
        end
    end
    def subscribe_project
        @donor=Donor.find(params[:donor_id])
        @project=Project.find(params[:id])
        if @donor.present? && @project.present?
            @donor.projects.push(@project)
            if @donor.save
                render json:@donor,status: :ok
            else
                render json:@donor.errors,status: :ok
            end
        else
            render json:{message:"No donor or project found"},status: :ok
        end
    end
    private
    def donor_params
        params.require(:donor).permit(:area_representative_id,:status,donor_user_attributes:[:name,:age,:phonenumber,:email,:guardian_name,:country,:pincode,:address,:gender,:id_card,:id_card_value,:is_onboarded,:pan,:latitude,:longitude],donor_subscription_attributes:[:subscription_id,:last_updated])
    end
    def update_donor_params
        params.require(:donor).permit(:id,:is_area_representative,:donor_reg_no,:role,:subscription_id,:area_representative_id,:status,donor_user_attributes:[:id,:name,:age,:phonenumber,:email,:guardian_name,:country,:pincode,:address,:gender,:id_card,:id_card_value,:is_onboarded,:pan])
    end
    def find_donor
        @donor=Donor.find(params[:id])
    end
    def validates_update
        if(params[:subscription_id].present? && get_subscription_id!=params[:subscription_id])
            subscription
        elsif(params[:status].present?)
            deactivate
        end
    end
    def subscription
        if(@donor.family_id != nil && @donor.group_head?)
            @family=@donor.family
            @family.subscription=Subscription.find(params[:subscription_id])
            @family.last_updated=false
            if @family.save
                render json: @family,status: :ok
            else
                render json: @family.errors,status: :unprocessable_entity
            end
        elsif(@donor.donor_subscription !=nil && @donor.individual_donor?)
            @donor.donor_subscription.subscription=Subscription.find(params[:subscription_id])
            @donor.donor_subscription.last_updated=false
            if @donor.save
                render json: @donor,include:['donor_subscription.subscription'],status: :ok
            else
                render json: @donor.errors,status: :unprocessable_entity
            end
        else
            render json: {status:"Update the subscription through your group head"},status: :unprocessable_entity
        end
    
    end
    def deactivate
        @donor.status=params[:status]
        if @donor.is_area_representative
            @donor_user=@donor.donor_user
            new_reps=DonorUser.joins(:donor).where(["is_area_representative = ? and donors.id != ?",true,"#{@donor.id}"]).select('latitude','longitude','donors.id')
            @new_rep=new_reps.map{|i| [@donor_user.distance_from([i.latitude,i.longitude]),i.id]}.min
            if(new_reps.length==0)
                    return render json: {status:"no nearby area representatives found"},status: :ok
            else
                if(params[:area_representative_id].present?)
                    @new_representative=Donor.find(params[:area_representative_id])
                else
                    @new_representative=Donor.find(@new_rep[1])
                end
                @donor.donators.map {|i| i.area_representative=@new_representative}
            end
        end
        if @donor.save
            render json: @donor,status: :ok
        else
            render json: @donor.errors,status: :unprocessable_entity
        end
    end
    def get_subscription_id
        if(@donor.family_id != nil)
            return @donor.family.subscription.id
        elsif(@donor.donor_subscription !=nil)
            return @donor.donor_subscription.subscription.id
        end
    end

end
