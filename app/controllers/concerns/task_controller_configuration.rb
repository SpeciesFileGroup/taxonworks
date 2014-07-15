module TaskControllerConfiguration
  extend ActiveSupport::Concern

  included do
    # attr_reader :set_is_data_controller
    before_filter :set_is_task_controller
  end

  protected

  def set_is_task_controller 
    @is_task_controller = true
  end 
end
