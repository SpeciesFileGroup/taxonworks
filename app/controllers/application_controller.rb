class ApplicationController < ActionController::Base
  include Workbench::SessionsHelper

  include Api::Intercept
  
  include ProjectsHelper # /helpers/projects_helper.rb
  include SetHousekeeping
  include SetExceptionNotificationData
  include Tracking::UserTime
  include Whitelist
  include Cookies
  include LogRecent  # disabled
  include PageMeta
  include ControllerTypes
  include RescueFrom
  include ForgeryProtection
  include PaginationHeaders
  include RequestType
end
