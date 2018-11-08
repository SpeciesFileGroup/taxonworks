module SetHousekeeping
  extend ActiveSupport::Concern

  included do
    before_action do
      Current.user_id = sessions_current_user_id
      Current.project_id = sessions_current_project_id
    end
  end
end
