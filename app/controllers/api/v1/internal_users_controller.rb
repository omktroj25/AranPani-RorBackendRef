class Api::V1::InternalUsersController < ApplicationController
    before_action :find_user,only:[:update,:destroy,:show]
    def create
        @user=User.new(user_params)
        @user.role=User.roles[:user]
        @user.password="123456789"
        if @user.save
            render json: @user,status: :ok
        else
            render json: @user.errors.messages,status: :unprocessable_entity
        end
    end
    def index
        @result=User.search(params).paginate(page:params[:page],per_page:params[:limit])
        render json: @result,status: :ok
    end
    def update
        if @user.update(user_params)
            render json: @user,status: :ok
        else
            render json: @user.errors.messages,status: :unprocessable_entity
        end
    end
    def destroy
        if @user.destroy
            render json: {status:"success"},status: :ok
        else
            render json: @user.errors.messages,status: :unprocessable_entity
        end
    end
    def show
        if @user.present?
            render json: @user,status: :ok
        else
            render json: @user.errors.messages,status: :unprocessable_entity
        end
    end
    private
    def user_params
        params.require(:internal_user).permit(:username,:email,:phonenumber,:status,permissions_attributes: [:scope])
    end
    def find_user
        @user=User.find(params[:id])
    end
end
