class Tasks::ObservationMatrices::ObservationMatrixHubController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @observation_matrices = ObservationMatrix.where(project_id: sessions_current_project_id).order(updated_at: :desc)
  end

  def copy_observations
    redirect_to :observation_matrices_hub_task, notice: 'Missing selection to clone.' and return if params[:old_otu_id].blank? || params[:new_otu_id.blank?]
    old = Otu.find(params.require(:old_otu_id))
    new = Otu.find(params.require(:new_otu_id))

    if Observation.copy(old.to_global_id.to_s, new.to_global_id.to_s)
      redirect_to :observation_matrices_hub_task, notice: 'Observation copy successful.'
    else
      redirect_to :observation_matrices_hub_task, notice: 'Observation copy unsuccessful.'
    end
  end

end
