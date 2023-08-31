class Api::V1::PaymentsController < ApplicationController
    before_action { authorize("donors") }
    def create
        # is_onboarded,is area rep active,
        @donor=Donor.find(params[:id])
        if @donor.status

            if @donor.individual_donor?
            elsif @donor.group_head?
            else
                render json:{status:"Deactivated donor"},status: :ok
            end
        else
            render json:{status:"Deactivated donor"},status: :ok
        end

        @payment=payment.new(payment_params)
        
    end
    private
    def payment_params
        params.require(:payment).permit(:mode,:is_one_time_payment,:transaction_id,:settled,:amount)
    end
end
