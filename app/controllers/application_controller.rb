class ApplicationController < ActionController::API
    before_action :doorkeeper_authorize!

    private
    def current_user
      return unless doorkeeper_token
      @current_user ||= User.find_by(id: doorkeeper_token[:resource_owner_id])
    end
    def authorize(scope)
      self.current_user
      @user=User.find(@current_user.id)
      if(@user.admin?)
        return
      end
      for i in @user.permissions
        if(i.scope.downcase==scope)
          return
        end
      end
      render json: {status:"failure"},status: :unauthorized
    end
end
