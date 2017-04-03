class MatrixColumnsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_matrix_column, only: [:show]

  # GET /matrix_columns
  # GET /matrix_columns.json
  def index
    @recent_objects = MatrixColumn.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /matrix_columns/1
  # GET /matrix_columns/1.json
  def show
  end

  def list
    @matrix_columns = MatrixColumn.with_project_id(sessions_current_project_id).page(params[:page])
  end

  private
  def set_matrix_column
    @matrix_column = MatrixColumn.find(params[:id])
  end

end
