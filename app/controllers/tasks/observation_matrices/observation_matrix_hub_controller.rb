class Tasks::ObservationMatrices::ObservationMatrixHubController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @observation_matrices = ObservationMatrix.where(project_id: sessions_current_project_id).order(updated_at: :desc)
  end

end
