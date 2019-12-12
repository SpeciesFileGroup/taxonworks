module SetExceptionNotificationData
  extend ActiveSupport::Concern

  included do
    before_action do
      user = sessions_current_user
      project = sessions_current_project
      data = {}

      data[:user] = { user_id: user&.id, user_email: user&.email }
      data[:project] = { project_id: project&.id, project_name: project&.name }

      request.env['exception_notifier.exception_data'] = data
    end
  end
end
