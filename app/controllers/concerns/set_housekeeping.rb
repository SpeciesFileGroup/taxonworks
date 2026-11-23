# Sets Current from the session. Named so that callers (e.g.
# TaskTokenAuthentication) can skip it; Current is otherwise set only by
# TaskTokenAuthentication.
module SetHousekeeping
  extend ActiveSupport::Concern

  included do
    before_action :set_housekeeping
  end

  protected

  def set_housekeeping
    Current.user_id = sessions_current_user_id
    Current.project_id = sessions_current_project_id
  end
end
