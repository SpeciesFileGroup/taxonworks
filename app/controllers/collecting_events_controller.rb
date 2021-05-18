class CollectingEventsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_collecting_event, only: [:show, :edit, :update, :destroy, :card, :clone, :navigation]
  after_action -> { set_pagination_headers(:collecting_events) }, only: [:index], if: :json_request?

  # GET /collecting_events
  # GET /collecting_events.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = CollectingEvent.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @collecting_events = Queries::CollectingEvent::Filter.new(filter_params).all.where(project_id: sessions_current_project_id).page(params[:page]).per(params[:per] || 500)
      }
    end
  end

  # GET /collecting_events/1
  # GET /collecting_events/1.json
  def show
  end

  # GET /collecting_events/new
  def new
    @collecting_event = CollectingEvent.new
  end

  # GET /collecting_events/1/edit
  def edit
  end

  # POST /collecting_events
  # POST /collecting_events.json
  def create
    @collecting_event = CollectingEvent.new(collecting_event_params)
    respond_to do |format|
      if @collecting_event.save
        format.html { redirect_to @collecting_event, notice: 'Collecting event was successfully created.' }
        format.json { render action: 'show', status: :created, location: @collecting_event }
      else
        format.html { render action: 'new' }
        format.json { render json: @collecting_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /collecting_events/1/clone.json
  def clone
    @collecting_event = @collecting_event.clone
    if @collecting_event.persisted?
      respond_to do |format|
        format.html { redirect_to new_collecting_event_task_path(@collecting_event), notice: 'Clone successful, editing new record.' }
        format.json { render :show }
      end
    else
      format.html { redirect_to new_collecting_event_task_path(@collecting_event), notice: 'Failed to clone the collecting event..' }
      format.json {render json: @collecting_event.errors, status: :unprocessable_entity}
    end
  end

  # PATCH/PUT /collecting_events/1
  # PATCH/PUT /collecting_events/1.json
  def update
    respond_to do |format|
      if @collecting_event.update(collecting_event_params)
        format.html { redirect_to @collecting_event, notice: 'Collecting event was successfully updated.' }
        format.json { render :show, status: :ok, location: @collecting_event }
      else
        format.html { render action: 'edit' }
        format.json { render json: @collecting_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collecting_events/1
  # DELETE /collecting_events/1.json
  def destroy
    @collecting_event.destroy
    respond_to do |format|
      if @collecting_event.destroyed?
        format.html { destroy_redirect @collecting_event, notice: 'CollectingEvent was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { destroy_redirect @collecting_event, notice: 'CollectingEvent was not destroyed: ' + @collecting_event.errors.full_messages.join('; ') }
        format.json { render json: @collecting_event.errors, status: :unprocessable_entity }
      end
    end
  end

  def card
    @target = params[:target]
  end

  def test
    @geo = CollectingEvent.test
  end

  def list
    @collecting_events = CollectingEvent.with_project_id(sessions_current_project_id).order(:id).page(params[:page])
  end

  def attributes
    render json: ::CollectingEvent.columns.select{
      |a| Queries::CollectingEvent::Filter::ATTRIBUTES.include?(
        a.name)
    }.collect{|b| {'name' => b.name, 'type' => b.type } }
  end

  # GET /collecting_events/search
  def search
    if params[:id].blank?
      redirect_to collecting_event_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to collecting_event_path(params[:id])
    end
  end

  def autocomplete
    @collecting_events = Queries::CollectingEvent::Autocomplete.new(params[:term], project_id: sessions_current_project_id).autocomplete
  end

  # GET /collecting_events/autocomplete_collecting_event_verbatim_locality?term=asdf
  # see rails-jquery-autocomplete
  def autocomplete_collecting_event_verbatim_locality
    term = params[:term]
    values = CollectingEvent.where(project_id: sessions_current_project_id).where('verbatim_locality ILIKE ?', term + '%').select(:verbatim_locality, 'length(verbatim_locality)').distinct.limit(20).order('length(verbatim_locality)').order('verbatim_locality ASC').all
    render json: values.map { |v| { label: v.verbatim_locality, value: v.verbatim_locality} }
  end

  # GET /collecting_events/download
  def download
    send_data(Export::Download.generate_csv(CollectingEvent.where(project_id: sessions_current_project_id)),
              type: 'text',
              filename: "collecting_events_#{DateTime.now}.csv")
  end

  # parse verbatim label, return date and coordinates
  def parse_verbatim_label
    if params[:verbatim_label]
      render json: {date: Utilities::Dates.date_regex_from_verbatim_label(params[:verbatim_label]),
                    geo: Utilities::Geo.coordinates_regex_from_verbatim_label(params[:verbatim_label]),
                    elevation: Utilities::Elevation.elevation_regex_from_verbatim_label(params[:verbatim_label]),
                    collecting_method: Utilities::CollectingMethods.method_regex_from_verbatim_label(params[:verbatim_label]),
      }.to_json
    end
  end

  # GET collecting_events/batch_load
  def batch_load
  end

  def preview_simple_batch_load
    if params[:file]
      @result = BatchLoad::Import::CollectingEvents.new(**batch_params)
      digest_cookie(params[:file].tempfile, :batch_collecting_events_md5)
      render 'collecting_events/batch_load/simple/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  def create_simple_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :batch_collecting_events_md5)
      @result = BatchLoad::Import::CollectingEvent.new(**batch_params)
      if @result.create
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} collecting events were created."
        render 'collecting_events/batch_load/simple/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :batch_load
  end

  def preview_castor_batch_load
    if params[:file]
      @result = BatchLoad::Import::CollectingEvents::CastorInterpreter.new(**batch_params)
      digest_cookie(params[:file].tempfile, :Castor_collecting_events_md5)
      render 'collecting_events/batch_load/castor/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  def create_castor_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :Castor_collecting_events_md5)
      @result = BatchLoad::Import::CollectingEvents::CastorInterpreter.new(**batch_params)
      if @result.create
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} collecting events were created."
        render 'collecting_events/batch_load/castor/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :batch_load
  end

  def preview_gpx_batch_load
    if params[:file]
      @result = BatchLoad::Import::CollectingEvents::GpxInterpreter.new(**batch_params)
      digest_cookie(params[:file].tempfile, :gpx_batch_load_collecting_events_md5)
      render 'collecting_events/batch_load/gpx/preview'
      # render '/shared/data/all/batch_load/preview'
    else
      flash[:notice] = "No file provided!"
      redirect_to action: :batch_load
    end
  end

  def create_gpx_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :gpx_batch_load_collecting_events_md5)
      @result = BatchLoad::Import::CollectingEvents::GpxInterpreter.new(**batch_params)
      if @result.create
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} collecting events w/georeferences were created."
        render 'collecting_events/batch_load/gpx/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :batch_load
  end

  # GET /collecting_events/select_options
  def select_options
    @collecting_events = CollectingEvent.select_optimized(sessions_current_user_id, sessions_current_project_id)
  end

  def api_index
    @collecting_events = Queries::CollectingEvent::Filter.new(api_params).all
      .where(project_id: sessions_current_project_id)
      .order('collecting_events.id')
      .page(params[:page]).per(params[:per])
    render 'collecting_events/api/v1/index'
  end

  def api_show
    @collecting_event = CollectingEvent.where(project_id: sessions_current_project_id).find(params[:id])
    render '/collecting_events/api/v1/show'
  end

  def api_autocomplete
    render json: {} and return if params[:term].blank?
    @collecting_events = Queries::CollectingEvent::Autocomplete.new(params[:term], project_id: sessions_current_project_id).autocomplete
    render '/collecting_events/api/v1/autocomplete'
  end

  def navigation
  end

  private

  def set_collecting_event
    @collecting_event = CollectingEvent.with_project_id(sessions_current_project_id).find(params[:id])
    @recent_object = @collecting_event
  end

  def collecting_event_params
    params.require(:collecting_event).permit(
      :verbatim_label, :print_label, :print_label_number_to_print, :document_label,
      :verbatim_locality, :verbatim_date, :verbatim_longitude, :verbatim_latitude,
      :verbatim_geolocation_uncertainty, :verbatim_trip_identifier, :verbatim_collectors,
      :verbatim_method, :geographic_area_id, :minimum_elevation, :maximum_elevation,
      :elevation_precision, :time_start_hour, :time_start_minute, :time_start_second,
      :time_end_hour, :time_end_minute, :time_end_second, :start_date_day,
      :start_date_month, :start_date_year, :end_date_day, :end_date_month,
      :group, :member, :formation, :lithology, :max_ma, :min_ma,
      :end_date_year, :verbatim_habitat, :field_notes, :verbatim_datum,
      :verbatim_elevation,
      roles_attributes: [:id, :_destroy, :type, :person_id, :position,
                         person_attributes: [:last_name, :first_name, :suffix, :prefix]],
    identifiers_attributes: [:id, :namespace_id, :identifier, :type, :_destroy],
    data_attributes_attributes: [ :id, :_destroy, :controlled_vocabulary_term_id, :type, :attribute_subject_id, :attribute_subject_type, :value ]
    )
  end

  def batch_params
    params.permit(
      :ce_namespace,
      :ce_geographic_area_id,
      :file,
      :import_level).merge(
        user_id: sessions_current_user_id,
        project_id: sessions_current_project_id).to_h.symbolize_keys
  end

  def filter_params
    params.permit(
      Queries::CollectingEvent::Filter::ATTRIBUTES,
      :collector_ids_or,
      :end_date,   # used in date range
      :geo_json,
      :in_labels,
      :in_verbatim_locality,
      :md5_verbatim_label,
      :partial_overlap_dates,
      :radius,
      :recent,
      :spatial_geographic_areas,
      :start_date, # used in date range
      :wkt,
      keyword_id_and: [],
      keyword_id_or: [],
      spatial_geographic_area_ids: [],
      geographic_area_id: [],
      otu_id: [],
      collector_id: [],
    )
  end

  def api_params
    params.permit(
      Queries::CollectingEvent::Filter::ATTRIBUTES,
      :collector_ids_or,
      :end_date,   # used in date range
      :geo_json,
      :in_labels,
      :in_verbatim_locality,
      :md5_verbatim_label,
      :partial_overlap_dates,
      :radius,
      :recent,
      :spatial_geographic_areas,
      :start_date, # used in date range
      :wkt,
      keyword_ids: [],
      spatial_geographic_area_ids: [],
      geographic_area_id: [],
      otu_id: [],
      collector_id: [],
    )
  end

end
