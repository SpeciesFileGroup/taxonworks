class Tasks::ObservationMatrices::ImageMatrixController < ApplicationController
  include TaskControllerConfiguration
  
  # GET /tasks/observation_matrices/image_matrix
  def index
  end

  # GET /tasks/observation_matrices/image_matrix/37/key
  def key
    byebug
    @key = Tools::ImageMatrix.new(**image_key_params)
  end

  protected

  #params[:observation_matrix_id, :project_id, :observation_matrix, :language_id, :keyword_ids, :row_filter,
  #       :per, :page, :otu_filter, :identified_to_rank]
  def image_key_params
    params.permit(
        :observation_matrix_id,
        :language_id,
        :row_filter,
        :otu_filter,
        :sorting,
        :eliminate_unknown,
        :error_tolerance,
        :identified_to_rank,
        :selected_descriptors,
        :per,
        :page,
        keyword_ids: [] # arrays must be at the end
    ).to_h.symbolize_keys.merge(project_id: sessions_current_project_id)
  end

end
