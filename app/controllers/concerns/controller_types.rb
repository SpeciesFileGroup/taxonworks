module ControllerTypes
  extend ActiveSupport::Concern

  included do
    attr_writer :is_data_controller, :is_task_controller

    # Returns true if the controller is that of data class. See controllers/concerns/data_controller_configuration/ concern.
    # Data controllers can not be task controllers.
    def is_data_controller?
      @is_data_controller
    end

    # Returns true if the controller is a task controller. See controllers/concerns/task_controller_configuration/ concern.
    # Task controllers can not be data controllers.
    def is_task_controller?
      @is_task_controller
    end

    helper_method :is_data_controller?, :is_task_controller?
  end
  
end
