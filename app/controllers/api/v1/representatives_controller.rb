class Api::V1::RepresentativesController < ApplicationController
    before_action { authorize("representative") }
    def index
        render json: Donor.representative_search(params).paginate(page:params[:page],per_page:params[:limit]),each_serializer:RepresentativeSerializer,scope:false,include:['donators.donor_user','donor_user','donor_subscription'],status: :ok
    end
    def show
        @representative=Donor.find_by(id:params[:id],is_area_representative:true)
        if @representative.present? 
            render json:@representative,serializer:RepresentativeSerializer,scope:true,include:['donators.donor_user','donor_user','donor_subscription'],status: :ok
        else
            render json: @representative.errors,status: :ok
        end
    end
    def update
        @representative=Donor.find_by(id:params[:id],is_area_representative:true)
        for i in params[:donor_ids]
            @representative.donators.push(Donor.find(i))
        end
        if @representative.save
            render json:@representative,serializer:RepresentativeSerializer,include:['donators.donor_user','donor_user','donor_subscription'],status: :ok
        else
            render json: @representative.errors,status: :ok
        end
    end
end
