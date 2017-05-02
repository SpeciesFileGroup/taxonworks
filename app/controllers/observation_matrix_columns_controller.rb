class ObservationMatrixColumnsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_observation_matrix_column, only: [:show]

  # GET /matrix_columns
  # GET /matrix_columns.json
  def index
    @recent_objects = ObservationMatrixColumn.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /matrix_columns/1
  # GET /matrix_columns/1.json
  def show
  end

  def list
    @observation_matrix_columns = ObservationMatrixColumn.with_project_id(sessions_current_project_id).page(params[:page])
  end

  private

  def set_observation_matrix_column
    @observation_matrix_column = ObservationMatrixColumn.find(params[:id])
  end

end
