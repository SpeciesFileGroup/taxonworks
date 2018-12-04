class Tasks::ObservationMatrices::ViewController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    q = ObservationMatrix.where(project_id: sessions_current_project_id)
    @observation_matrix = params[:id] ? q.find(params[:id]) : q.first
    redirect_to new_observation_matrix_task_path and return if @observation_matrix.nil?
  end

end
