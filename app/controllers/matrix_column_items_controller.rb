class MatrixColumnItemsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  before_action :set_matrix_column_item, only: [:show, :edit, :update, :destroy]

  # GET /matrix_column_items
  # GET /matrix_column_items.json
  def index
    @recent_objects = MatrixColumnItem.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /matrix_column_items/1
  # GET /matrix_column_items/1.json
  def show
  end

  def list
    @matrix_column_items = MatrixColumnItem.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # GET /matrix_column_items/new
  def new
    @matrix_column_item = MatrixColumnItem.new
  end

  # GET /matrix_column_items/1/edit
  def edit
  end

  # POST /matrix_column_items
  # POST /matrix_column_items.json
  def create
    @matrix_column_item = MatrixColumnItem.new(matrix_column_item_params)

    respond_to do |format|
      if @matrix_column_item.save
        format.html { redirect_to @matrix_column_item.metamorphosize, notice: 'Matrix column item was successfully created.' }
        format.json { render :show, status: :created, location: @matrix_column_item }
      else
        format.html { render :new }
        format.json { render json: @matrix_column_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /matrix_column_items/1
  # PATCH/PUT /matrix_column_items/1.json
  def update
    respond_to do |format|
      if @matrix_column_item.update(matrix_column_item_params)
        format.html { redirect_to @matrix_column_item.metamorphosize, notice: 'Matrix column item was successfully updated.' }
        format.json { render :show, status: :ok, location: @matrix_column_item }
      else
        format.html { render :edit }
        format.json { render json: @matrix_column_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /matrix_column_items/1
  # DELETE /matrix_column_items/1.json
  def destroy
    @matrix_column_item.destroy
    respond_to do |format|
      format.html { redirect_to matrix_column_items_url, notice: 'Matrix column item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_matrix_column_item
      @matrix_column_item = MatrixColumnItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def matrix_column_item_params
      params.require(:matrix_column_item).permit(:matrix_id, :type, :descriptor_id, :keyword_id)
    end
end
