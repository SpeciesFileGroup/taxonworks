class Tasks::Usage::UserActivityController < ApplicationController

#  TODO: FIX THIS

  include TaskControllerConfiguration
  def index
    @project_members = User.all # Project.find(@sessions_current_project_id).users
  end

  def report
    @user = User.find(params[:id])
  end

end