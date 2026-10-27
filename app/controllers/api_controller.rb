# !! No authentication included at this level, maybe
# only logging/throttling etc.
#
# ! Endpoint authentication requrements are set in routes via defaults: referenced in includes
class ApiController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  include Api::AuthenticateUserToken
  include Api::AuthenticateProjectToken
  include RequestType
  include PaginationHeaders

  # Unlike ActionController::Base only the matching helper (ApiHelper) is
  # included, `extend[]`, `embed[]` and `exclude[]` are used in these views.
  helper RestHelper
  # include Api::RescueFrom

end
