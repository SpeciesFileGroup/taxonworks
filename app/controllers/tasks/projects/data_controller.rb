class Tasks::Projects::DataController < ApplicationController
  include TaskControllerConfiguration

  # GET task/projects/data
  def index
    @project = Project.find(sessions_current_project_id)
  end

end
