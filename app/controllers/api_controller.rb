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

  protected

end
