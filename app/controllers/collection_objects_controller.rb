class CollectionObjectsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_collection_object, only: [:show, :edit, :update, :destroy, :containerize,
                                               :depictions, :images, :geo_json]

  # GET /collection_objects
  # GET /collection_objects.json
  def index
    @recent_objects = CollectionObject.recent_from_project_id(sessions_current_project_id)
      .order(updated_at: :desc)
      .includes(:identifiers, :taxon_determinations)
      .limit(10)
    render '/shared/data/all/index'
  end

  # GET /collection_objects/1
  # GET /collection_objects/1.json
  def show
  end

  # GET /collection_objects/depictions/1
  # GET /collection_objects/depictions/1.json
  def depictions
  end

  # GET /collection_objects/1/images
  # GET /collection_objects/1/images.json
  def images
    @images = @collection_object.images
  end

  # GET /collection_objects/1/geo_json
  # GET /collection_objects/1/geo_json.json
  def geo_json
    ce = @collection_object.collecting_event
    @geo_json = ce.nil? ? nil : ce.to_geo_json_feature
  end

  # GET /collection_objects/by_identifier/ABCD
  def by_identifier
    @identifier = params.require(:identifier)
    @request_project_id = sessions_current_project_id
    @collection_objects = CollectionObject.with_identifier(@identifier).where(project_id: @request_project_id).all

    raise ActiveRecord::RecordNotFound if @collection_objects.empty?
  end

  # GET /collection_objects/new
  def new
    @collection_object = CollectionObject.new
  end

  # GET /collection_objects/1/edit
  def edit
  end

  # POST /collection_objects
  # POST /collection_objects.json
  def create
    @collection_object = CollectionObject.new(collection_object_params)

    respond_to do |format|
      if @collection_object.save
        format.html { redirect_to url_for(@collection_object.metamorphosize), notice: 'Collection object was successfully created.' }
        format.json { render action: 'show', status: :created, location: @collection_object.metamorphosize }
      else
        format.html { render action: 'new' }
        format.json { render json: @collection_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collection_objects/1
  # PATCH/PUT /collection_objects/1.json
  def update
    respond_to do |format|
      if @collection_object.update(collection_object_params)
        @collection_object = @collection_object.metamorphosize
        format.html { redirect_to url_for(@collection_object), notice: 'Collection object was successfully updated.' }
        format.json { render :show, status: :ok, location: @collection_object }
      else
        format.html { render action: 'edit' }
        format.json { render json: @collection_object.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collection_objects/1
  # DELETE /collection_objects/1.json
  def destroy
    @collection_object.destroy
    respond_to do |format|
      format.html { redirect_to collection_objects_url, notice: 'Collection object was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /collection_objects/list
  def list
    @collection_objects = CollectionObject.with_project_id(sessions_current_project_id)
      .order(:id)
      .page(params[:page]) #.per(10) #.per(3)
  end

  # GET /collection_object/search
  def search
    if params[:id].blank?
      redirect_to collection_object_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to collection_object_path(params[:id])
    end
  end

  def autocomplete
    @collection_objects =
      Queries::BiologicalCollectionObjectAutocompleteQuery.new(
        params[:term],
        project_id: sessions_current_project_id
    ).autocomplete

    data = @collection_objects.collect do |t|
      {id: t.id,
       label: ApplicationController.helpers.collection_object_tag(t),
       gid: t.to_global_id.to_s,
       response_values: {
         params[:method] => t.id
       },
       label_html: ApplicationController.helpers.collection_object_tag(t)
      }
    end
    render json: data
  end

  # GET /collection_objects/download
  def download
    send_data Download.generate_csv(CollectionObject.where(project_id: sessions_current_project_id), header_converters: []), type: 'text', filename: "collection_objects_#{DateTime.now}.csv"
  end

  # GET collection_objects/batch_load
  def batch_load
  end

  def preview_simple_batch_load
    if params[:file]
      @result = BatchLoad::Import::CollectionObjects.new(batch_params.merge(user_map))
      digest_cookie(params[:file].tempfile, :batch_collection_objects_md5)
      render 'collection_objects/batch_load/simple/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  def create_simple_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile,
                                                :batch_collection_objects_md5)
      @result = BatchLoad::Import::CollectionObjects.new(batch_params.merge(user_map))
      if @result.create
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} collection object-related object-sets were created."
        render 'collection_objects/batch_load/simple/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :batch_load
  end

  def containerize
    @container_item = ContainerItem.new(contained_object: @collection_object)
  end

  def preview_castor_batch_load
    if params[:file]
      @result = BatchLoad::Import::CollectionObjects::CastorInterpreter.new(batch_params)
      digest_cookie(params[:file].tempfile, :Castor_collection_objects_md5)
      render 'collection_objects/batch_load/castor/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  def create_castor_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :Castor_collection_objects_md5)
      @result = BatchLoad::Import::CollectionObjects::CastorInterpreter.new(batch_params)
      if @result.create
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} items were created."
        render 'collection_objects/batch_load/castor/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :batch_load
  end

  def preview_buffered_batch_load
    if params[:file]
      @result = BatchLoad::Import::CollectionObjects::BufferedInterpreter.new(batch_params)
      digest_cookie(params[:file].tempfile, :Buffered_collection_objects_md5)
      render 'collection_objects/batch_load/buffered/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  def create_buffered_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :Buffered_collection_objects_md5)
      @result = BatchLoad::Import::CollectionObjects::BufferedInterpreter.new(batch_params)
      if @result.create
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} items were created."
        render 'collection_objects/batch_load/buffered/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :batch_load
  end

  def select_options
    @collection_objects = CollectionObject.select_optimized(sessions_current_user_id, sessions_current_project_id, params.require(:target))
  end

  private

  def set_collection_object
    @collection_object = CollectionObject.with_project_id(sessions_current_project_id).find(params[:id])
    @recent_object     = @collection_object
  end

  def collection_object_params
    params.require(:collection_object).permit(
      :total, :preparation_type_id, :repository_id,
      :ranged_lot_category_id, :collecting_event_id,
      :buffered_collecting_event, :buffered_determinations,
      :buffered_other_labels, :deaccessioned_at, :deaccession_reason,
      :contained_in,
      collecting_event_attributes: []
    )
  end

  def batch_params
    params.permit(:file, :import_level, :source_id, :otu_id)
        .merge(user_id: sessions_current_user_id, project_id: sessions_current_project_id).to_h.symbolize_keys
  end

  def user_map
    {user_header_map: {
      'otu'         => 'otu_name',
      'start_day'   => 'start_date_day',
      'start_month' => 'start_date_month',
      'start_year'  => 'start_date_year',
      'end_day'     => 'end_date_day',
      'end_month'   => 'end_date_month',
      'end_year'    => 'end_date_year'}}
  end

end

require_dependency Rails.root.to_s + '/lib/batch_load/import/collection_objects/castor_interpreter.rb'
