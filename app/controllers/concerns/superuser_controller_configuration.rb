module SuperuserControllerConfiguration
  extend ActiveSupport::Concern

  included do
    before_action :require_superuser_sign_in
    before_action :set_is_task_controller

  end

  protected

  def set_is_task_controller
    @is_task_controller = true
  end
end
