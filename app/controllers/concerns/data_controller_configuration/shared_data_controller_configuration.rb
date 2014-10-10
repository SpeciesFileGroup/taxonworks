module DataControllerConfiguration::SharedDataControllerConfiguration
  extend ActiveSupport::Concern

  included do
    include DataControllerConfiguration
    before_action :require_sign_in
  end

  protected

end
