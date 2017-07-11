module DataControllerConfiguration::SharedDataControllerConfiguration
  extend ActiveSupport::Concern

  included do
    include DataControllerConfiguration
    before_action :require_sign_in
    before_action :set_is_shared_data_model
  end

  protected

  def set_is_shared_data_model
    @is_shared_data_model = true
  end

end
