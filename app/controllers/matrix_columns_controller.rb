class MatrixColumnsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  
  before_action :set_matrix_column, only: [:show, :edit, :update, :destroy]

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

  # GET /matrix_columns/new
  def new
    @matrix_column = MatrixColumn.new
  end

  # GET /matrix_columns/1/edit
  def edit
  end

  # POST /matrix_columns
  # POST /matrix_columns.json
  def create
    @matrix_column = MatrixColumn.new(matrix_column_params)

    respond_to do |format|
      if @matrix_column.save
        format.html { redirect_to @matrix_column, notice: 'Matrix column was successfully created.' }
        format.json { render :show, status: :created, location: @matrix_column }
      else
        format.html { render :new }
        format.json { render json: @matrix_column.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /matrix_columns/1
  # PATCH/PUT /matrix_columns/1.json
  def update
    respond_to do |format|
      if @matrix_column.update(matrix_column_params)
        format.html { redirect_to @matrix_column, notice: 'Matrix column was successfully updated.' }
        format.json { render :show, status: :ok, location: @matrix_column }
      else
        format.html { render :edit }
        format.json { render json: @matrix_column.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /matrix_columns/1
  # DELETE /matrix_columns/1.json
  def destroy
    @matrix_column.destroy
    respond_to do |format|
      format.html { redirect_to matrix_columns_url, notice: 'Matrix column was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_matrix_column
      @matrix_column = MatrixColumn.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def matrix_column_params
      params.require(:matrix_column).permit(:matrix_id, :descriptor_id, :position, :created_by_id, :updated_by_id, :project_id)
    end
end
