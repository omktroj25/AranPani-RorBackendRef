class Api::V1::PasswordController < ApplicationController
    skip_before_action :doorkeeper_authorize!
    def forgot
        @user=User.find_by(email:params[:email])
        if @user.present?
            @user.generate_reset_token!
            ResetmailerMailer.reset_password(@user,"http://127.0.0.1/api/v1/password/"+@user.reset_password_token+"/reset").deliver_now
            render json:{token:@user.reset_password_token},status: :ok
        else
            render json:{email:"Invalid email"},status: :unprocessable_entity
        end
    end
    def reset
        @token=params[:id]
        if @token.present?
            @user=User.find_by(reset_password_token:@token)
            if @user.present? && @user.reset_password_token_valid?
                if @user.reset_password!(params[:password])
                    render json: {status:"success"},status: :ok
                else
                    render json: @user.errors,status: :unprocessable_entity
                end
            else
                render json: {status:"Link not valid or expired"},status: :unprocessable_entity
            end
        else
            render json: {status:"Token is missing"},status: :unprocessable_entity
        end

    end
end
