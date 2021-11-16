class IdentifiersController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_identifier, only: [:update, :destroy, :show]

  # GET /identifiers
  # GET /identifiers.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = Identifier.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @identifiers = Queries::Identifier::Filter.new(params).all
          .where(project_id: sessions_current_project_id).page(params[:page]).per(params[:per] || 500)
      }
    end
  end

  # GET /identifers/1
  def show
  end

  # GET /identifers
  def new
    @identifier = Identifier.new(identifier_params)
  end

  # GET /identifers/1/edit
  def edit
    @identifier = Identifier.find_by_id(params[:id]).metamorphosize
  end

  # POST /identifiers
  # POST /identifiers.json
  def create
    @identifier = Identifier.new(identifier_params)
    respond_to do |format|
      if @identifier.save
        format.html { redirect_to url_for(@identifier.identifier_object.metamorphosize),
                      notice: 'Identifier was successfully created.' }
        format.json { render action: 'show', status: :created, location: @identifier.becomes(Identifier) }
      else
        format.html { render 'new', notice: 'Identifier was NOT successfully created.' }
        format.json { render json: @identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /identifiers/1
  # PATCH/PUT /identifiers/1.json
  def update
    respond_to do |format|
      if @identifier.update(identifier_params)
        format.html { redirect_to url_for(@identifier.identifier_object.metamorphosize),
                      notice: 'Identifier was successfully updated.' }
        format.json { render :show, status: :ok, location: @identifier.becomes(Identifier) }
      else
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Identifier was NOT successfully created.')}
        format.json { render json: @identifier.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /identifiers/1
  # DELETE /identifiers/1.json
  def destroy
    @identifier.destroy
    respond_to do |format|
      format.html { destroy_redirect @identifier, notice: 'Identifier was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @identifiers = Identifier.where(project_id: sessions_current_project_id).includes(:updater).page(params[:page])
  end

  # GET /identifier/search
  def search
    if @identifier = Identifier.find(params[:id])
      redirect_to url_for(@identifier.identifier_object.metamorphosize)
    else
      redirect_to identifier_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    end
  end

  def autocomplete
    render json: {} and return if params[:term].blank?
    @identifiers = Queries::Identifier::Autocomplete.new(params.require(:term), **autocomplete_params).autocomplete
  end

  # GET /api/v1/identifiers
  def api_index
    @identifiers = Queries::Identifier::Filter.new(api_params).all
      .order('identifiers.id').page(params[:page]).per(params[:per])
    render '/identifiers/api/v1/index'
  end

  # GET /api/v1/identifiers/:id
  def api_show
    @identifier = Identifier.where(project_id: sessions_current_project_id).find(params[:id])
    render '/identifiers/api/v1/show'
  end

  def api_autocomplete
    render json: {} and return if params[:term].blank?
    @identifiers = Queries::Identifier::Autocomplete.new(params.require(:term), **autocomplete_params).autocomplete
    render '/identifiers/api/v1/autocomplete'
  end


  # GET /identifiers/download
  def download
    send_data Export::Download.generate_csv(Identifier.where(project_id: sessions_current_project_id)), type: 'text', filename: "identifiers_#{DateTime.now}.csv"
  end

  # GET /identifiers/identifier_types
  def identifier_types
    render json: IDENTIFIERS_JSON
  end

  private

  def set_identifier
    @identifier = Identifier.with_project_id(sessions_current_project_id).find(params[:id])
  end

  def api_params
    params.permit(
      :query_string,
      :identifier,
      :identifier_object_id,
      :identifier_object_type,
      :namespace_id,
      :namespace_name,
      :namespace_short_name,
      :object_global_id,
      :type,
      identifier_object_id: [],
      identifier_object_type: [],
    )
  end

  def identifier_params
    params.require(:identifier).permit(
      :id, :identifier_object_id, :identifier_object_type, :identifier, :type, :namespace_id, :annotated_global_entity
    )
  end

  def autocomplete_params
    params.permit(identifier_object_type: []).to_h.symbolize_keys.merge(project_id: sessions_current_project_id) # :exact
  end

end
