class Api::V1::RepresentativesController < ApplicationController
    before_action { authorize("representative") }
    def index
        render json: search,status: :ok
    end
    
    private
    def search
        Donor.joins(:donor_user).where(["name LIKE ? or email LIKE ? or phonenumber LIKE ? or donor_reg_no LIKE ?","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%"]).where("is_area_representative = ?",true).paginate(page:params[:page],per_page:params[:limit])
    end
end
