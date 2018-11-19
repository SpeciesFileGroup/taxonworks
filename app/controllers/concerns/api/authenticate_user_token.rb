module Api

  # See AuthenticateProjectToken for documentation
  module AuthenticateUserToken 

    extend ActiveSupport::Concern
    
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include TokenAuthentication

    included do
      before_action :intercept_user, if: -> { params[:authenticate_user] }
    end

  end
end
