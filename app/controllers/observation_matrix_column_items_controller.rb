class ObservationMatrixColumnItemsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  before_action :set_observation_matrix_column_item, only: [:show, :edit, :update, :destroy]

  # GET /observation_matrix_column_items
  # GET /observation_matrix_column_items.json
  def index
    @recent_objects = ObservationMatrixColumnItem.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /observation_matrix_column_items/1
  # GET /observation_matrix_column_items/1.json
  def show
  end

  def list
    @observation_matrix_column_items = ObservationMatrixColumnItem.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # GET /observation_matrix_column_items/new
  def new
    @observation_matrix_column_item = ObservationMatrixColumnItem.new
  end

  # GET /observation_matrix_column_items/1/edit
  def edit
  end

  # POST /observation_matrix_column_items
  # POST /observation_matrix_column_items.json
  def create
    @observation_matrix_column_item = ObservationMatrixColumnItem.new(observation_matrix_column_item_params)

    respond_to do |format|
      if @observation_matrix_column_item.save
        format.html { redirect_to @observation_matrix_column_item.metamorphosize, notice: 'Matrix column item was successfully created.' }
        format.json { render :show, status: :created, location: @observation_matrix_column_item }
      else
        format.html { render :new }
        format.json { render json: @observation_matrix_column_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /observation_matrix_column_items/1
  # PATCH/PUT /observation_matrix_column_items/1.json
  def update
    respond_to do |format|
      if @observation_matrix_column_item.update(observation_matrix_column_item_params)
        format.html { redirect_to @observation_matrix_column_item.metamorphosize, notice: 'Matrix column item was successfully updated.' }
        format.json { render :show, status: :ok, location: @observation_matrix_column_item }
      else
        format.html { render :edit }
        format.json { render json: @observation_matrix_column_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /observation_matrix_column_items/1
  # DELETE /observation_matrix_column_items/1.json
  def destroy
    @observation_matrix_column_item.destroy
    respond_to do |format|
      format.html { redirect_to observation_matrix_column_items_url, notice: 'Matrix column item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_observation_matrix_column_item
    @observation_matrix_column_item = ObservationMatrixColumnItem.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def observation_matrix_column_item_params
    params.require(:observation_matrix_column_item).permit(:observation_matrix_id, :type, :descriptor_id, :keyword_id)
  end
end
