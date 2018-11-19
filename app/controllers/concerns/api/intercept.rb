module Api
  module Intercept 

    extend ActiveSupport::Concern
   
    include ActionController::HttpAuthentication::Token::ControllerMethods
    # include ActionController::HttpAuthentication::Token

    include TokenAuthentication 

    # Handle CORS here as well likely 

    # headers['Access-Control-Allow-Origin'] = '*'
    # headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    # headers['Access-Control-Request-Method'] = '*'
    # headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'

    included do
      before_action :intercept_api, if: -> { /^\/api/ =~ request.path }
    end

    # @return [True, render]
    #   If authentication is requried, as defined in the routes, 
    #   then it must pass here.
    def intercept_api
      intercept_user if params[:authenticate_user]
      intercept_project if params[:authenticate_project]
      set_project_from_params if params[:project_id]
      true
    end

  end
end
