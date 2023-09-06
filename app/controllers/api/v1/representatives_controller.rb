class Api::V1::RepresentativesController < ApplicationController
    before_action { authorize("representative") }
    def index
        render json: search,each_serializer:RepresentativeSerializer,include:['donators.donor_user','donor_user','donor_subscription'],status: :ok
    end
    def show
        @representative=Donor.find(params[:id])
        if @representative.present? 
            render json:@representative,serializer:RepresentativeSerializer,include:['donators.donor_user','donor_user','donor_subscription'],status: :ok
        else
            render json: @representative.errors,status: :ok
        end
    end
    def update
        @representative=Donor.find_by(id:params[:id],is_area_representative:true)
        for i in params[:donor_ids]
            @representative.donators.push(Donor.find(i))
        end
        if @representative.present? 
            render json:@representative,serializer:RepresentativeSerializer,include:['donators.donor_user','donor_user','donor_subscription'],status: :ok
        else
            render json: @representative.errors,status: :ok
        end
    end
    private
    def search
        Donor.joins(:donor_user).where(["name LIKE ? or email LIKE ? or phonenumber LIKE ? or donor_reg_no LIKE ?","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%"]).where("is_area_representative = ?",true).paginate(page:params[:page],per_page:params[:limit])
    end
end
