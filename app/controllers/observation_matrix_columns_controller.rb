class ObservationMatrixColumnsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_observation_matrix_column, only: [:show]

  # GET /matrix_columns
  # GET /matrix_columns.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = ObservationMatrixColumn.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json { 
        @observation_matrix_columns = ObservationMatrixColumn.where(filter_params).where(project_id: sessions_current_project_id).order('observation_matrix_columns.position')
      }
    end
  end

  # GET /matrix_columns/1
  # GET /matrix_columns/1.json
  def show
  end

  def list
    @observation_matrix_columns = ObservationMatrixColumn.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # POST /observation_matrix_columns/sort?id[]=1&id[]=2
  def sort
    ObservationMatrixColumn.sort(params.require(:ids))
    head :no_content 
  end

  private

  def filter_params
    params.permit(:descriptor_id, :observation_matrix_id)
  end

  def set_observation_matrix_column
    @observation_matrix_column = ObservationMatrixColumn.find(params[:id])
  end

end
