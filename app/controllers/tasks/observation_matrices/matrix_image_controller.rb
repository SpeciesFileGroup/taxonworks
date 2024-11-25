class Tasks::ObservationMatrices::MatrixImageController < ApplicationController
  include TaskControllerConfiguration

  def index
    if ObservationMatrix.where(project_id: sessions_current_project_id).none?
      redirect_to :observation_matrices_hub_task, alert: 'Create an observation matrix first.' and return
    end
  end

end
