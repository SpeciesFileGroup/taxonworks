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
    @observation_matrix_row_items = ObservationMatrixRowItem.with_project_id(sessions_current_project_id)
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
    @observation_matrix_row_item.destroy
    respond_to do |format|
      if @observation_matrix_row_item.destroyed?
        format.html { redirect_to observation_matrix_row_items_url,
                      notice: 'Matrix row item was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Observation matrix row item was not destroyed, ' + @observation_matrix_row_item.errors.full_messages.join('; '))}
        format.json {render json: @observation_matrix_row_item.errors, status: :unprocessable_entity}
      end
    end
  end

  # POST /observation_matrix_row_items/batch_create?batch_type=tags&observation_matrix_id=123&keyword_id=456&klass=Otu
  # POST /observation_matrix_row_items/batch_create?batch_type=pinboard&observation_matrix_id=123&klass=Otu
  def batch_create
    if @loan_items = ObservationMatrixRowItem.batch_create(batch_params)
      render :index
    else
      render json: {success: false}
    end 
  end

  private

  def batch_params
    params.permit(:batch_type, :observation_matrix_id, :keyword_id, :klass).to_h.symbolize_keys.merge(project_id: sessions_current_project_id, user_id: sessions_current_user_id)
  end

  def filter_params
    params.permit(
      :observation_matrix_id, :otu_id, :controlled_vocabulary_term_id, :collection_object_id, :type, :taxon_name_id)
  end

  def set_observation_matrix_row_item
    @observation_matrix_row_item = ObservationMatrixRowItem.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def observation_matrix_row_item_params
    params.require(:observation_matrix_row_item).permit(
      :observation_matrix_id, :type,
      :observation_object_type, :observation_object_id,
      :taxon_name_id,
      :controlled_vocabulary_term_id, :type, :position)
  end
end
