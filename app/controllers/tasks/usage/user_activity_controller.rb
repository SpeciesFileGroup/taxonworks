class Tasks::Usage::UserActivityController < ApplicationController
  include TaskControllerConfiguration

  def index
    @project_members = Project.find(@sessions_current_project_id).users
  end

  def report
    @user = User.find(params[:id])
  end


end
