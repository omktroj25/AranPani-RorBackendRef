class Api::V1::DonorsController < ApplicationController
    before_action { authorize("donors") }
    def index
        render json: search,status: :ok
    end
    def create
        @donor=Donor.new(donor_params)
        if !Subscription.find(@donor.donor_subscription.subscription.id).status
            render json:{status:false,message:"Subscription was deactivated by the admin"},status: :ok
            return
        end
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
        @donor=Donor.find(params[:id])
        @donor.status=params[:status]
        if @donor.is_area_representative
            new_reps=DonorUser.joins(:donor).where(["is_area_representative = ? and donors.id != ?",true,"#{@donor.id}"]).near([@donor.donor_user.latitude,@donor.donor_user.longitude],50)
            if(new_reps.length==0)
                    render json: {status:"no nearby area representatives found"},status: :ok
                    return
            else
                if(params[:area_representative_id].present?)
                    @new_representative=Donor.find(params[:area_representative_id])
                else
                    @new_representative=new_reps[0].donor
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
    def find
        @donor_user=DonorUser.find_by(phonenumber:params[:phonenumber])
        render json: @donor_user.donor,status: :ok
    end
    def promote_rep
        @donor=Donor.find(params[:id])
        if @donor.group_member?
            render json:{status:false,message:"Group member can't be promoted"},status: :ok
            return
        end
        @donor.area_representative_id=@donor.id
        @donor.is_area_representative=true
        if @donor.group_head?
            @family=@donor.family
            lt=[]
            for i in @family.donors
                i.area_representative=@donor
                lt.push(i)
            end
            @family.donors=lt
            @family.save
        end
        if @donor.save
            render json: @donor,status: :ok
        else
            render json: @donor.errors,status: :unprocessable_entity
        end
    end
    def show
        @donor=Donor.find(params[:id])
        render json: @donor,status: :ok
    end
    def get_payments
        @donor=Donor.find(params[:id])
        stats={"Financial donations"=>0}
        stats["Total donations"]=@donor.payments.sum("amount")
        json_response={"stats"=>stats,"payments"=>@donor.payments.map{|i| PaymentSerializer.new(i,scope:false)}}
        render json: json_response,status: :ok
    end
    def add_payment
        @donor=Donor.find(params[:id])
        if !@donor.donor_user.is_onboarded
            render json:{status:false,message:"Donor not yet onboarded"},status: :ok
            return
        elsif !@donor.status
            render json:{status:false,message:"Deactivated donor"},status: :ok
            return
        elsif @donor.group_member?
            render json:{status:false,message:"Donate through your group head"},status: :ok
            return
        end
        if @donor.individual_donor?
            if @donor.donor_subscription.last_updated
                donor_subscription_histories=@donor.donor_subscription.donor_subscription_histories
                if donor_subscription_histories.length==0
                    @donor.donor_subscription.donor_subscription_histories.push(DonorSubscriptionHistory.new(subscription:@donor.donor_subscription.subscription,last_paid:Time.now))
                end
            else
                @donor.donor_subscription.donor_subscription_histories.push(DonorSubscriptionHistory.new(subscription:@donor.donor_subscription.subscription,last_paid:Time.now))
                @donor.donor_subscription.last_updated=true
            end
            @donor.donor_subscription.last_paid=Time.now
            @donor.save!
            @donor_subscription_history=@donor.donor_subscription.donor_subscription_histories.last
            @donor_subscription_history.last_paid=Time.now
            @payment=Payment.new(payment_params)
            # @payment.payment_date=Time.now
            @payment.donor=@donor
            @payment.area_representative=@donor.area_representative
            @donor_subscription_history.payments.push(@payment)
            @donor_subscription_history.save
        else
            @family=@donor.family
            if @family.last_updated
                @family_history=@donor.family_histories.last
            else
                @family_history=FamilyHistory.new(head:@donor,count:@family.count,last_paid:Time.now,subscription:@family.subscription)
                for i in @family.donors
                    @family_history.donors.push(i)
                end
                @family.last_updated=true
            end
            @family.last_paid=Time.now
            @family_history.last_paid=Time.now
            @family.save
            @payment=Payment.new(payment_params)
            # @payment.payment_date=Time.now
            @payment.donor=@donor
            @payment.area_representative=@donor.area_representative
            @family_history.payments.push(@payment)
        end
        render json:{status:"success"},status: :ok
        
    end
    def demote_rep
        @old_representative=Donor.find(params[:id])
        @new_representative=Donor.find_by(id:params[:representative_id],is_area_representative:true)
        for i in @old_representative.donators
            i.area_representative=@new_representative
        end
        @old_representative.is_area_representative=false
        @old_representative.save
        if @new_representative.save
            render json: @new_representative,serializer:RepresentativeSerializer,include:['donators.donor_user','donor_user','donor_subscription'],status: :ok
        else
            render json: @new_representative.errors,status: :ok
        end
    end
    def settle_payment
        @payment=Payment.find(params[:id])
        @payment.settled=true
        if @payment.save
            render json: @payment,status: :ok
        else
            render json: @payment.errors,stats: :ok
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
    def payment_params
        params.require(:payment).permit(:mode,:is_one_time_payment,:transaction_id,:settled,:amount)
    end
end
