module SetExceptionNotificationData
  extend ActiveSupport::Concern

  included do
    before_action do
      user = User.find(Current.user_id) if Current.user_id
      project = Project.find(Current.project_id) if Current.project_id
      data = {}

      data[:user] = { user_id: user&.id, user_email: user&.email }
      data[:project] = { project_id: project&.id, project_name: project&.name }

      request.env['exception_notifier.exception_data'] = data
    end
  end
end
