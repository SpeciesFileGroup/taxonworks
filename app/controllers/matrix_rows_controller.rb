class MatrixRowsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
 
  before_action :set_matrix_row, only: [:show, :edit, :update, :destroy]
 
  # GET /matrices
  # GET /matrices.json
  def index
    @recent_objects = MatrixRow.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /matrix_rows/1
  # GET /matrix_rows/1.json
  def show
  end

  def list
    @matrix_rows = MatrixRow.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # GET /matrix_rows/new
  def new
    @matrix_row = MatrixRow.new
  end

  # GET /matrix_rows/1/edit
  def edit
  end

  # POST /matrix_rows
  # POST /matrix_rows.json
  def create
    @matrix_row = MatrixRow.new(matrix_row_params)

    respond_to do |format|
      if @matrix_row.save
        format.html { redirect_to @matrix_row, notice: 'Matrix row was successfully created.' }
        format.json { render :show, status: :created, location: @matrix_row }
      else
        format.html { render :new }
        format.json { render json: @matrix_row.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /matrix_rows/1
  # PATCH/PUT /matrix_rows/1.json
  def update
    respond_to do |format|
      if @matrix_row.update(matrix_row_params)
        format.html { redirect_to @matrix_row, notice: 'Matrix row was successfully updated.' }
        format.json { render :show, status: :ok, location: @matrix_row }
      else
        format.html { render :edit }
        format.json { render json: @matrix_row.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /matrix_rows/1
  # DELETE /matrix_rows/1.json
  def destroy
    @matrix_row.destroy
    respond_to do |format|
      format.html { redirect_to matrix_rows_url, notice: 'Matrix row was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_matrix_row
      @matrix_row = MatrixRow.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def matrix_row_params
      params.require(:matrix_row).permit(:matrix_id, :otu_id, :collection_object_id, :position, :created_by_id, :updated_by_id, :project_id)
    end
end
