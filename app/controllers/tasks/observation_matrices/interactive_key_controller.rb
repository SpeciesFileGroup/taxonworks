class Tasks::ObservationMatrices::InteractiveKeyController < ApplicationController
  include TaskControllerConfiguration

  # GET /tasks/observation_matrices/interactive_key
  def index
  end

  # GET /tasks/observation_matrices/interactive_key/37/key
  def key
    @key = Tools::InteractiveKey.new(**key_params)
  end

  # GET /api/v1/observation_matrices/123/key.json
  def api_key
    @key = Tools::InteractiveKey.new(**key_params)
    render '/tasks/observation_matrices/interactive_key/key'
  end

  protected

  # params[:observation_matrix_id, :project_id, :observation_matrix, :language_id, :keyword_ids, :row_filter, :otu_filter,
  #       :sorting, :eliminate_unknown, :error_tolerance, :identified_to_rank, :selected_descriptors]
  def key_params
    params.permit(
      :eliminate_unknown,
      :error_tolerance,
      :identified_to_rank,
      :language_id,
      :observation_matrix_id,
      :otu_filter,
      :row_filter,
      :selected_descriptors,
      :sorting,
      keyword_ids: [] # arrays must be at the end
    ).to_h.symbolize_keys.merge(project_id: sessions_current_project_id)
  end

end
