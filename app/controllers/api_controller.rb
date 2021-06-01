
# !! No authentication included at this level, maybe
# only logging/throttling etc.
#
# ! Endpoint authentication requrements are set in routes vi defaults: referenced in includes
class ApiController < ActionController::API

    include ActionController::HttpAuthentication::Token::ControllerMethods

    include Api::AuthenticateUserToken
    include Api::AuthenticateProjectToken
    include RequestType
    include PaginationHeaders

    # attr_accessor :permitted_projects
    # before_action :set_permitted_projects

    protected

    #def set_permitted_projects
    #  @permitted_projects = sessions_current_user.projects
    #end

end
