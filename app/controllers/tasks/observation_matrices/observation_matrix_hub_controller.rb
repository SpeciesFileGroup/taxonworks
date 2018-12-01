class Tasks::ObservationMatrices::ObservationMatrixHubController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @observation_matrices = ObservationMatrix.where(project_id: sessions_current_project_id).order(updated_at: :desc)
  end

  def copy_observations
    old = Otu.find(params.require(:old_otu_id))
    new = Otu.find(params.require(:new_otu_id))

    if Observation.copy(old.to_global_id.to_s, new.to_global_id.to_s)
      redirect_to :index_observation_matrix_hub_task, notice: 'Observation copy successful.'
    else
      redirect_to :index_observation_matrix_hub_task, notice: 'Observation copy unsuccessful.'
    end
  end

end
