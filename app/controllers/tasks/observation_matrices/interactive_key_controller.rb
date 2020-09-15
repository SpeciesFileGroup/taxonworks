class Tasks::ObservationMatrices::InteractiveKeyController < ApplicationController
  include TaskControllerConfiguration
  include DataControllerConfiguration::ProjectDataControllerConfiguration


  #params[:observation_matrix_id, :project_id, :observation_matrix, :language_id, :keyword_ids, :row_filter,
  #       :sorting, :eliminate_unknown, :error_tolerance, :identified_to_rank, :selected_descriptors]
  def index
    respond_to do |format|
      format.html do
        @observation_matrix = ObservationMatrix.where(project_id: sessions_current_project_id, id: params[:observation_matrix_id]).first unless params[:observation_matrix_id].blank?
        #    redirect_to new_observation_matrix_path and return if @observation_matrix.nil?
      end
      format.json {
        @observation_matrix = InteractiveKey.new(filter_params)
      }
    end
  end

  def interactive_key_params
    params.require(:observation_matrix).permit(
    :observation_matrix_id,
        :project_id,
        :language_id,
        :keyword_ids,
        :row_filter,
        :sorting,
        :eliminate_unknown,
        :error_tolerance,
        :identified_to_rank,
        :selected_descriptors
    )
  end
  def filter_params
    params.permit(
        :observation_matrix_id,
        :project_id,
        :language_id,
        :keyword_ids,
        :row_filter,
        :sorting,
        :eliminate_unknown,
        :error_tolerance,
        :identified_to_rank,
        :selected_descriptors
    )
  end


end