class ConfidencesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_confidence, only: [:edit, :update, :destroy]
  after_action -> { set_pagination_headers(:confidences) }, only: [:index, :api_index ], if: :json_request?

  # GET /confidences
  # GET /confidences.json
  # GET /<model>/:id/confidences.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = ::Confidence.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @confidences = ::Queries::Confidence::Filter.new(params).all.where(project_id: sessions_current_project_id).
        page(params[:page]).per(params[:per] || 500)
      }
    end
  end

  # GET /confidences/new
  def new
    @confidence_object = confidence_object
  end

  # GET /confidences/1/edit
  def edit
  end

  def list
    @confidences = Confidence.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # POST /confidences
  # POST /confidences.json
  def create
    @confidence = Confidence.new(confidence_params)
    respond_to do |format|
      if @confidence.save
        format.html { redirect_to url_for(@confidence.confidence_object.metamorphosize), notice: 'Confidence was successfully created.' }
        format.json { render :show, status: :created, location: @confidence }
      else
        format.html {
          redirect_back(fallback_location: (request.referer || root_path), notice: 'Confidence was NOT successfully created.')
        }
        format.json { render json: @confidence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /confidences/1
  # PATCH/PUT /confidences/1.json
  def update
    respond_to do |format|
      if @confidence.update(confidence_params)
        format.html { redirect_to @confidence, notice: 'Confidence was successfully updated.' }
        format.json { render :show, status: :ok, location: @confidence }
      else
        format.html { render :edit }
        format.json { render json: @confidence.errors, status: :unprocessable_entity }
      end
    end
  end

  def confidence_object_update 
    @confidence_object = confidence_object
    if @confidence_object.update(confidences_params)
      flash[:notice] = 'Successfully updated record.'
    else
      flash[:error] = "Error updating record: #{@confidence_object.errors.full_messages.join('; ')}."
    end
    redirect_to new_confidence_path(confidence_object_type: @confidence_object.class.name, confidence_object_id: @confidence_object.id.to_s)
  end

  # DELETE /confidences/1
  # DELETE /confidences/1.json
  def destroy
    @confidence.destroy
    respond_to do |format|
      format.html { redirect_to confidences_url, notice: 'Confidence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to confidences_path, notice: 'You must select an item from the list with a click or tab press before clicking show'
    else
      redirect_to confidence_path(params[:id])
    end
  end

  # GET /confidences/download
  def download
    send_data Export::Download.generate_csv(Confidence.where(project_id: sessions_current_project_id)), type: 'text', filename: "confidences_#{DateTime.now}.csv"
  end

  def exists
    if @confidence = Confidence.exists?(params.require(:global_id),
        params.require(:confidence_level_id),
        sessions_current_project_id)
      render :show
    else
      render json: false
    end
  end

  private

  def set_confidence
    @confidence = Confidence.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def confidence_params
    params.require(:confidence).permit(
      :annotated_global_entity,
      :confidence_level_id, :confidence_object_id, :confidence_object_type,
      confidence_level_attributes: [:_destroy, :id, :name, :definition, :uri, :uri_relation]
    )
  end

  def confidence_object
    a = params[:confidence_object_type]
    b = params[:confidence_object_id]
    if a && b && o = whitelist_constantize(a)&.find(b)
      o
    else
      redirect_to confidences_path, alert: 'Object paramaters confidence_object_type and confidence_object_id were not provided.' and return
    end
  end

  def confidences_params
    params.require(:confidence_object).permit(
      :annotated_global_entity,
      :confidence_level_id,
      confidence_level_attributes: [:_destroy, :id, :name, :definition, :uri, :uri_relation]
    )
  end

end
