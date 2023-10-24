class Api::V1::SubscriptionsController < ApplicationController
    def index
        render json:Subscription.all.page(params[:page]),status: :ok
    end
    def update
        @subscription=Subscription.find(params[:id])
        @subscription.status=params[:status]
        if @subscription.save
            render json: {status:"success"},status: :ok
        else
            render json: @subscription.errors,status: :unprocessable_entity
        end
    end
end
