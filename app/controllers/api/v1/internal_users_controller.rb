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
    def index
        @result=search
        render json: @result,status: :ok
    end
    def update
        @user=User.find(params[:id])
        if @user.update(user_params)
            render json: @user,status: :ok
        else
            render json: @user.errors.messages,status: :unprocessable_entity
        end
    end
    def destroy
        @user=User.find(params[:id])
        if @user.destroy
            render json: {status:"success"},status: :ok
        else
            render json: @user.errors.messages,status: :unprocessable_entity
        end
    end
    def show
        @user=User.find(params[:id])
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
    def search
        User.where(["username LIKE ? or email LIKE ? or phonenumber LIKE ?","%#{params[:search]}%","%#{params[:search]}%","%#{params[:search]}%"]).paginate(page:params[:page],per_page:params[:limit])
    end
end
