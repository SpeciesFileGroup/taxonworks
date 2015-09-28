module TaskControllerConfiguration
  extend ActiveSupport::Concern

  included do
    # attr_reader :set_is_data_controller
    before_filter :set_is_task_controller
    before_action :require_sign_in_and_project_selection
  end

  protected

  def set_is_task_controller 
    @is_task_controller = true
  end 
end
