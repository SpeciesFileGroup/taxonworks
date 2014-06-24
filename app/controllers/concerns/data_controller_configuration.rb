module DataControllerConfiguration
  extend ActiveSupport::Concern

  included do
    # attr_reader :set_is_data_controller
    before_filter :set_is_data_controller
  end

  protected

  def set_is_data_controller 
    @is_data_controller = true
  end 
end
