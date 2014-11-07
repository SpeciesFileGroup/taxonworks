module DataControllerConfiguration::ProjectDataControllerConfiguration 
  extend ActiveSupport::Concern

  included do
    include DataControllerConfiguration
    before_action :require_sign_in_and_project_selection
  end

  protected

end
