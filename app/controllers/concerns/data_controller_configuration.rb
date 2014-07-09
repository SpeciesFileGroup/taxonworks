module DataControllerConfiguration
  extend ActiveSupport::Concern

  included do
    before_action :require_sign_in_and_project_selection
    before_filter :set_is_data_controller, :set_data_class
  end

  protected

  def set_is_data_controller 
    @is_data_controller = true
  end 

  def set_data_class
    @data_class = controller_name.classify.constantize
  end 

  # instance_variable_set("@#{controller_name}", objects)



end
