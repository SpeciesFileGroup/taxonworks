module LogRecent
  extend ActiveSupport::Concern

  # after_action :log_user_recent_route

  # TODO: Make RecenRoutes modules that handles exceptions, only etc.
  def log_user_recent_route
    # sessions_current_user.add_recently_visited_to_footprint(request.fullpath, @recent_object) if sessions_current_user
  end

end
