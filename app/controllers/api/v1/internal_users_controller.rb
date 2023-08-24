class Api::V1::InternalUsersController < ApplicationController
    def create
        @user=User.new(user_params)
        @user.role=User.roles[:user]
        @user.password="123456789"
        p @user.permissions
        if @user.save
            render json: @user,status: :ok
        else
            render json: @user.errors.messages,status: :unprocessable_entity
        end
    end
    private
    def user_params
        params.require(:internal_user).permit(:username,:email,:phonenumber,:status,permissions_attributes: [:scope])
    end
end
