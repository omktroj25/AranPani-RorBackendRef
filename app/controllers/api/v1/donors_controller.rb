class Api::V1::DonorsController < ApplicationController
    before_action { authorize("donors") }
    def index
        render json: {status:"success"}
    end
end
