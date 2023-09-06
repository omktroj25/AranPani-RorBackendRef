class Api::V1::PaymentsController < ApplicationController
    before_action { authorize("payments") }
    def index
        stats=group_by_mode.merge(group_by_settlement)
        if params[:is_one_time_payment].present?
            render json: {"stats":stats,"payments":one_time_payment_search.map{|i| PaymentSerializer.new(i,scope:true)}},status: :ok
        else
            render json: {"stats":stats,"payments":search.map{|i| PaymentSerializer.new(i,scope:true)}},status: :ok
        end
    end
    def create
        if params[:donor][:id].present?
            @donor=Donor.find(params[:donor][:id])
            @donor.payments.push(@payment=Payment.new(mode:params[:payments][:mode],is_one_time_payment:params[:payments][:is_one_time_payment],transaction_id:params[:payments][:transaction_id],amount:params[:payments][:amount],settled:params[:payments][:settled]))
            @payment.area_representative=@donor.area_representative
            @donor.payments.push(@payment)
        else
            @donor=Donor.new(payment_params)
            @sequence_generator=SequenceGenerator.find_by(model:"donor")
            seq=@sequence_generator.seq_no
            @donor.donor_reg_no="DON"+@sequence_generator.seq_no.to_s
            @sequence_generator.update(seq_no:seq+1)
            @donor.is_area_representative=false
            @donor.role=Donor.roles[:individual_donor]
            @donor.save
            if @donor.save
                @donor.payments.push(@payment=Payment.new(mode:params[:payments][:mode],is_one_time_payment:params[:payments][:is_one_time_payment],transaction_id:params[:payments][:transaction_id],amount:params[:payments][:amount],settled:params[:payments][:settled]))
            else
                render json:@donor.errors,status: :ok
                return
            end
           
        end
        # @donor.payments[0].payment_date=Time.now
        if @donor.save
            render json: @donor.payments,status: :ok
        else
            render json: @donor.errors,status: :ok
        end
    end
    private
    def payment_params
        params.require(:donor).permit(:area_representative_id,:status,donor_user_attributes:[:name,:age,:phonenumber,:email,:guardian_name,:country,:pincode,:address,:gender,:id_card,:id_card_value,:is_onboarded,:pan])
    end
    def search
        Payment.where(["strftime('%m', payment_date) = ? and strftime('%Y', payment_date) = ?", "#{Date::ABBR_MONTHNAMES.index(params[:month]).to_s.rjust(2,'0')}","#{params[:year]}"]).paginate(page:params[:page],per_page:params[:limit])
    end
    def one_time_payment_search
        Payment.where(["strftime('%m', payment_date) = ? and strftime('%Y', payment_date) = ? and is_one_time_payment=?", "#{Date::ABBR_MONTHNAMES.index(params[:month]).to_s.rjust(2,'0')}","#{params[:year]}",params[:is_one_time_payment] == "true" ? true : false]).paginate(page:params[:page],per_page:params[:limit])
    end
    def group_by_mode
        Payment.where(["strftime('%m', payment_date) = ? and strftime('%Y', payment_date) = ?", "#{Date::ABBR_MONTHNAMES.index(params[:month]).to_s.rjust(2,'0')}","#{params[:year]}"]).group("mode").sum("amount")
    end
    def group_by_settlement
        Payment.where(["strftime('%m', payment_date) = ? and strftime('%Y', payment_date) = ?", "#{Date::ABBR_MONTHNAMES.index(params[:month]).to_s.rjust(2,'0')}","#{params[:year]}"]).group("settled").sum("amount")
    end
end
