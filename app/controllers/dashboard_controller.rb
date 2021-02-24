class DashboardController < ApplicationController

  # GET '/'
  def index
    redirect_to signin_path, status: 301 and return unless sessions_signed_in?
    @projects = sessions_current_user.projects.order(:name)
  end

end
