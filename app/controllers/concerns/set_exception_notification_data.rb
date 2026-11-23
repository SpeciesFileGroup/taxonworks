module SetExceptionNotificationData
  extend ActiveSupport::Concern

  included do
    before_action :set_exception_notification_data
  end

  protected

  # Named so that it can be skipped (e.g. TaskTokenAuthentication), as it reads the session.
  def set_exception_notification_data
    user = sessions_current_user
    project = sessions_current_project
    data = {}

    data[:user] = { user_id: user&.id, user_email: user&.email }
    data[:project] = { project_id: project&.id, project_name: project&.name }

    request.env['exception_notifier.exception_data'] = data
  end
end
