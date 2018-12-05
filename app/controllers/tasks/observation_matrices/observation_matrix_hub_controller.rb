class Tasks::ObservationMatrices::ObservationMatrixHubController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @observation_matrices = ObservationMatrix.where(project_id: sessions_current_project_id).order(updated_at: :desc)
  end

  def copy_observations
    if Observation.copy(old.to_global_id.to_s, new.to_global_id.to_s)
      render json: {success: true, status: :created}
    else
      render json: {success: false, status: :unprocessable_entity }
    end
  end

end
