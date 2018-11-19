module Api

  # Authenticates project_token as required by params assigned in routes.
  # If authentication fails a JSON response indicating the failure is returned.
  module AuthenticateProjectToken 
    
    extend ActiveSupport::Concern

    include ActionController::HttpAuthentication::Token::ControllerMethods
    include TokenAuthentication 

    included do
      before_action :intercept_project, if: -> { params[:authenticate_project] }
    end
 
  end
end
