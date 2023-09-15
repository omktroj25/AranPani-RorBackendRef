class Api::V1::Meta::DonorsController < ApplicationController
    def find
        @donor_user=DonorUser.where("#{params[:field]}=?",params[:value])
        if @donor_user.present?
            render json: @donor_user,each_serializer:DonorMetaSerializer,status: :ok
        else
            render json: {status:false,message:"Donor not found"},status: :ok
        end
    end
end
