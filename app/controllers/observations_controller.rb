class ObservationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_observation, only: [:show, :edit, :update, :destroy, :annotations]
  after_action -> { set_pagination_headers(:observations) }, only: [:index, :api_index], if: :json_request? 

  # GET /observations
  # GET /observations.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Observation.recent_from_project_id(sessions_current_project_id)
          .order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @observations = Queries::Observation::Filter.new(params)
          .all
          .where(project_id: sessions_current_project_id)
          .page(params[:page])
          .per(params[:per])
      }
    end
  end

  def api_index
    @observations = Queries::Observation::Filter.new(api_params).all
      .with_project_id(sessions_current_project_id)
      .page(params[:page])
      .per(params[:per])

    render '/observations/api/v1/index'
  end

  def api_show
    @observation = Observation.where(project_id: sessions_current_project_id).find(params[:id])
    render '/observations/api/v1/show'
  end

  # GET /observations/1
  # GET /observations/1.json
  def show
  end

  # GET /observations/new
  def new
    @observation = Observation.new
  end

  # GET /observations/1/edit
  def edit
  end

  def list
    @observations = Observation.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # POST /observations
  # POST /observations.json
  def create
    @observation = Observation.new(observation_params)
    respond_to do |format|
      if @observation.save
        format.html {
          redirect_to observation_path(@observation.metamorphosize),
          notice: 'Observation was successfully created.' }
        format.json { render :show, status: :created, location: @observation.metamorphosize }
      else
        format.html { render :new }
        format.json { render json: @observation.metamorphosize.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /observations/1
  # PATCH/PUT /observations/1.json
  def update
    respond_to do |format|
      if @observation.update(observation_params)
        format.html { redirect_to url_for(@observation.metamorphosize),
                      notice: 'Observation was successfully updated.' }
        format.json { render :show, status: :ok, location: @observation.metamorphosize }
      else
        format.html { render :edit }
        format.json { render json: @observation.metamorphosize.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /observations/1
  # DELETE /observations/1.json
  def destroy
    @observation.destroy
    respond_to do |format|
      if @observation.destroyed?
        format.html { destroy_redirect @observation, notice: 'Observation was successfully destroyed.' }
        format.json { head :no_content}
      else
        format.html { destroy_redirect @observation, notice: 'Observation was not destroyed, ' + @observation.errors.full_messages.join('; ') }
        format.json { render json: @observation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /observations/destroy_row.json?observation_matrix_row_id=123
  def destroy_row
    @observation_matrix_row = ObservationMatrixRow.where(project_id: sessions_current_project_id).find(params.require(:observation_matrix_row_id))
    if Observation.destroy_row(@observation_matrix_row.id)
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  # DELETE /observations/destroy_column.json?observation_matrix_column_id=123
  def destroy_column
    @observation_matrix_column = ObservationMatrixColumn.where(project_id: sessions_current_project_id).find(params.require(:observation_matrix_column_id))
    if Observation.destroy_column(@observation_matrix_column.id)
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  # POST /observations/code_column.json?observation_matrix_column_id=123&observation_matrix_id=456&<observation params>
  def code_column
    if o = ObservationMatrixColumn.where(project_id: sessions_current_project_id).find(params[:observation_matrix_column_id])
      render json: Observation.code_column(params[:observation_matrix_column_id], observation_params )
    end
  end

  # GET /annotations
  def annotations
    @object = @observation
    render '/shared/data/all/annotations'
  end

  private

  def set_observation
    @observation = Observation.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def observation_params
    params.require(:observation).permit(
      :character_state_id, :frequency,
      :continuous_value, :continuous_unit,
      :day_made,
      :day_made,
      :description,
      :descriptor_id,
      :month_made,
      :month_made,
      :observation_object_global_id,
      :observation_object_type, :observation_object_id,
      :presence,
      :sample_n, :sample_min, :sample_max, :sample_median, :sample_mean, :sample_units, :sample_standard_deviation, :sample_standard_error,
      :time_made,
      :time_made,
      :type,
      :year_made,
      :year_made,
      images_attributes: [:id, :_destroy, :image_file, :rotate],
      depictions_attributes: [
        :id,
        :_destroy,
        :depiction_object_id, :depiction_object_type,
        :annotated_global_entity, :caption,
        :is_metadata_depiction,
        :image_id,
        :figure_label,
        image_attributes: [:image_file]
      ]
    )
  end

  def api_params
    params.permit(
      :collection_object_id,
      :descriptor_id,
      :observation_matrix_id,
      :observation_object_global_id,
      :otu_id
    ).to_h
  end

end
