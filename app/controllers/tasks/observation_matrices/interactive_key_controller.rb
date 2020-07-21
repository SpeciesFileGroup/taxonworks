class Tasks::ObservationMatrices::InteractiveKeyController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index

    @observation_matrix = ObservationMatrix.where(project_id: sessions_current_project_id, id: params[:observation_matrix_id]).first unless params[:observation_matrix_id].blank?
#    redirect_to new_observation_matrix_path and return if @observation_matrix.nil?
  end

end