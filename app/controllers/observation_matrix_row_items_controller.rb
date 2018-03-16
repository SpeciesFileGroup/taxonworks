class ObservationMatrixRowItemsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_observation_matrix_row_item, only: [:show, :edit, :update, :destroy]

  # GET /observation_matrix_row_items
  # GET /observation_matrix_row_items.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = ObservationMatrixRowItem.recent_from_project_id(sessions_current_project_id)
          .order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @observation_matrix_row_items = ObservationMatrixRowItem.where(filter_params).with_project_id(sessions_current_project_id)
      }
    end
  end

  # GET /observation_matrix_row_items/1
  # GET /observation_matrix_row_items/1.json
  def show
  end

  def list
    @observation_matrix_row_items = ObservationMatrixRow.with_project_id(sessions_current_project_id)
      .page(params[:page])
  end

  # GET /observation_matrix_row_items/new
  def new
    @observation_matrix_row_item = ObservationMatrixRowItem.new
  end

  # GET /observation_matrix_row_items/1/edit
  def edit
  end

  # POST /observation_matrix_row_items
  # POST /observation_matrix_row_items.json
  def create
    @observation_matrix_row_item = ObservationMatrixRowItem.new(observation_matrix_row_item_params)

    respond_to do |format|
      if @observation_matrix_row_item.save
        format.html { redirect_to url_for(@observation_matrix_row_item.metamorphosize),
                      notice: 'Matrix row item was successfully created.' }
        format.json { render :show, status: :created, location: @observation_matrix_row_item.metamorphosize }
      else
        format.html { render :new }
        format.json { render json: @observation_matrix_row_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /observation_matrix_row_items/1
  # PATCH/PUT /observation_matrix_row_items/1.json
  def update
    respond_to do |format|
      if @observation_matrix_row_item.update(observation_matrix_row_item_params)
        format.html { redirect_to url_for(@observation_matrix_row_item.metamorphosize),
                      notice: 'Matrix row item was successfully updated.' }
        format.json { render :show, status: :ok, location: @observation_matrix_row_item.metamorphosize }
      else
        format.html { render :edit }
        format.json { render json: @observation_matrix_row_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /observation_matrix_row_items/1
  # DELETE /observation_matrix_row_items/1.json
  def destroy
    @observation_matrix_row_item.destroy!
    respond_to do |format|
      format.html { redirect_to observation_matrix_row_items_url,
                    notice: 'Matrix row item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def filter_params
    params.permit(
      :observation_matrix_id, :otu_id, :controlled_vocabulary_term_id, :collection_object_id, :type)
  end

  def set_observation_matrix_row_item
    @observation_matrix_row_item = ObservationMatrixRowItem.find(params[:id])
  end

  def observation_matrix_row_item_params
    params.require(:observation_matrix_row_item).permit(
      :observation_matrix_id, :type,
      :collection_object_id, :otu_id,
      :controlled_vocabulary_term_id, :type, :position)
  end
end
