class Tasks::ObservationMatrices::ImageMatrixController < ApplicationController
  include TaskControllerConfiguration
  
  # GET /tasks/observation_matrices/image_matrix
  def index
  end

  # GET /tasks/observation_matrices/image_matrix/37/key
  def key
    # In-app, signed-in view: show everything, regardless of attribution.
    @key = Tools::ImageMatrix.new(**image_key_params, attributed_images_only: false)
  end

  # GET /api/v1/observation_matrices/123/image_matrix.json
  def api_key
    # Attributed-only by default; pass attributed_images_only=false to opt out.
    @key = Tools::ImageMatrix.new(**image_key_params, attributed_images_only: params[:attributed_images_only] != 'false')
    render '/observation_matrices/api/v1/image_matrix'
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
