class Tasks::ObservationMatrices::ViewController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    q = ObservationMatrix.where(project_id: sessions_current_project_id)
    @observation_matrix = params[:observation_matrix_id] ? q.find(params[:observation_matrix_id]) : q.first
    redirect_to new_observation_matrix_path and return if @observation_matrix.nil?
  end

end
