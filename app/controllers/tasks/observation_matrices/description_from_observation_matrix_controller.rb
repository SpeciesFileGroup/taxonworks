class Tasks::ObservationMatrices::DescriptionFromObservationMatrixController < ApplicationController
  include TaskControllerConfiguration
  #include DataControllerConfiguration::ProjectDataControllerConfiguration

  # GET /tasks/observation_matrices/description_from_observation_matrix
  def index
  end

  # GET /tasks/observation_matrices/description_from_observation_matrix/37/description
  def description
    @description = Tools::Description::FromObservationMatrix.new(**description_params)
  end

  protected

  def description_params
    params.permit(
      :observation_matrix_id,
      :include_descendants,
      :language_id,
      :observation_matrix_row_id,
      :otu_id,
      keyword_ids: [] # arrays must be at the end
    ).to_h.symbolize_keys.merge(project_id: sessions_current_project_id)
  end

end
