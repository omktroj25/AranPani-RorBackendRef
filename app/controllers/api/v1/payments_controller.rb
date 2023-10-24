class Api::V1::PaymentsController < ApplicationController
    before_action { authorize("payments") }
    include SequenceGeneratorService
    def index
        stats=Payment.group_by_mode(params).merge(Payment.group_by_settlement(params))
        if params[:is_one_time_payment].present?
            render json: {"stats":stats,"payments":Payment.one_time_payment_search(params).paginate(page:params[:page],per_page:params[:limit]).map{|i| PaymentSerializer.new(i,scope:true)}},status: :ok
        else
            render json: {"stats":stats,"payments":Payment.search(params).paginate(page:params[:page],per_page:params[:limit]).map{|i| PaymentSerializer.new(i,scope:true)}},status: :ok
        end
    end
    def create
        begin
            ActiveRecord::Base.transaction do
                if params[:donor][:id].present?
                    @donor=Donor.find(params[:donor][:id])
                    @payment=Payment.new(mode:params[:payments][:mode],is_one_time_payment:params[:payments][:is_one_time_payment],transaction_id:params[:payments][:transaction_id],amount:params[:payments][:amount],settled:params[:payments][:settled])
                    @payment.area_representative=@donor.area_representative
                    @donor.payments.push(@payment)
                else
                    @donor=Donor.new(payment_params)
                    @donor.donor_reg_no="DON"+sequence_generator('donor').to_s
                    @donor.is_area_representative=false
                    @donor.role=Donor.roles[:individual_donor]
                    @donor.save!
                    @donor.payments.push(@payment=Payment.new(mode:params[:payments][:mode],is_one_time_payment:params[:payments][:is_one_time_payment],transaction_id:params[:payments][:transaction_id],amount:params[:payments][:amount],settled:params[:payments][:settled]))
                end
                @donor.save!
                render json: @donor.payments,status: :ok
            end
        rescue Exception=>e
            render json:{status:e.message},status: :ok
            Rails.logger.error e
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
    def get_payments
        @donor=Donor.find(params[:id])
        stats={"Financial donations"=>0}
        stats["Total donations"]=@donor.payments.sum("amount")
        json_response={"stats"=>stats,"payments"=>@donor.payments.map{|i| PaymentSerializer.new(i,scope:false)}}
        render json: json_response,status: :ok
    end
    def add_payment
        @donor=Donor.find(params[:id])
        return render json:{status:false,message:"Donor not yet onboarded"},status: :ok if !@donor.donor_user.is_onboarded
        return render json:{status:false,message:"Deactivated donor"},status: :ok if !@donor.status
        return render json:{status:false,message:"Donate through your group head"},status: :ok if @donor.group_member?
        begin
            ActiveRecord::Base.transaction do
                if @donor.individual_donor?
                    @donor.donor_subscription.last_paid=Time.now
                    @donor.save!
                    @payment=Payment.new(payment_donor_params)
                    update_params={'donor_id'=>@donor.id,'area_representative_id'=>@donor.area_representative.id,'subscription_id'=>@donor.donor_subscription.subscription.id}
                    @payment.update!(update_params)
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
                    @family.save!
                    @payment=Payment.new(payment_donor_params)
                    @payment.donor=@donor
                    @payment.area_representative=@donor.area_representative
                    @family_history.payments.push(@payment)
                    @family_history.save!
                end
                render json:{status:"success"},status: :ok  
            end
        rescue Exception=>e
            render json:{status:e.message},status: :ok
            Rails.logger.error e
        end
    end
    private
    def payment_params
        params.require(:donor).permit(:id,:area_representative_id,:status,donor_user_attributes:[:name,:age,:phonenumber,:email,:guardian_name,:country,:pincode,:address,:gender,:id_card,:id_card_value,:is_onboarded,:pan],payments:[:mode,:transaction_id,:amount,:is_one_time_payment])
    end
    def payment_donor_params
        params.permit(:mode,:is_one_time_payment,:transaction_id,:settled,:amount)
    end
end
