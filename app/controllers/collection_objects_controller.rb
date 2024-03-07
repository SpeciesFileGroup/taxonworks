class CollectionObjectsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_collection_object, only: [
    :show, :edit, :update, :destroy, :navigation, :containerize,
    :depictions, :images, :geo_json, :metadata_badge, :biocuration_classifications,
    :timeline,
    :api_show, :api_dwc]
  after_action -> { set_pagination_headers(:collection_objects) }, only: [:index, :api_index], if: :json_request?

  # GET /collecting_events
  # GET /collecting_events.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = CollectionObject.recent_from_project_id(sessions_current_project_id)
          .order(updated_at: :desc)
          .includes(:identifiers, :taxon_determinations)
          .limit(10)
        render '/shared/data/all/index'
      end
      format.json do
        collection_objects = ::Queries::CollectionObject::Filter.new(params).all

        @collection_objects = add_includes_to_filter_result(collection_objects)

        @collection_objects = @collection_objects
          .page(params[:page])
          .per(params[:per])
      end
    end
  end

  # /collection_objects/index_metadata/.json
  def index_metadata
    render json: metadata_index( {
      repository: Repository,
      current_respository: Repository,
      collecting_event: CollectingEvent,
      taxon_determinations: TaxonDetermination })
      .merge( dwc_occurrence:  DwcOccurrence.target_columns.inject({}){|hsh,p| hsh[p] = nil; hsh}.delete_if{|k,v| k =~ /(_id|_type)\z/} )
      .merge( CollectionObject.core_attributes.inject({}){|hsh,p| hsh[p] = nil; hsh})
      .merge(
        identifiers: nil,
        object_tag: nil,
        object_label: nil,
      ).delete_if{|k,v| k =~ /(_id|_type)\z/}
  end

  # TODO: probably some deep clean
  # TODO: Move
  def metadata_index(models = {})
    h = {}
    models.each do |l, m|
      h.merge!(
        l => m.core_attributes.inject({}){|hsh,p| hsh[p] = nil; hsh}
      )
    end
    h
  end

  # GET /collection_objects/1
  # GET /collection_objects/1.json
  def show
  end

  # GET /collection_objects/1/timeline.json
  def timeline
    @data = ::Catalog::CollectionObject.data_for(@collection_object)
  end

  def biocuration_classifications
    @biocuration_classifications = @collection_object.biocuration_classifications
    render '/biocuration_classifications/index'
  end

  def navigation
  end

  # DEPRECATED
  # GET /collection_objects/dwca/123 # SHOULD BE dwc
  def dwca
    @dwc_occurrence = CollectionObject.includes(:dwc_occurrence).find(params[:id]).get_dwc_occurrence # find or compute for
    render json: @dwc_occurrence.to_json
  end

  # Render DWC fields *only*
  def dwc_index
    objects = ::Queries::CollectionObject::Filter.new(params).all.order('collection_objects.id').includes(:dwc_occurrence).page(params[:page]).per(params[:per]).all
    assign_pagination(objects)

    # Default to *exclude* some big fields, like geo-spatial wkt
    mode = params[:mode] || :view
    @objects = objects.pluck(*::CollectionObject.dwc_attribute_vector(mode))
    @headers = ::CollectionObject.dwc_attribute_vector_names(mode)
    render '/dwc_occurrences/dwc_index'
  end

  # GET /collection_objects/123/dwc
  def dwc
    o = nil
    ActiveRecord::Base.connection_pool.with_connection do
      o = CollectionObject.find(params[:id])
      if params[:rebuild] == 'true'
        # get does not rebuild, but does set if it doesn't exist
        o.set_dwc_occurrence
      else
        o.get_dwc_occurrence
      end

      # Default to *exclude* some fields that include large text, like geospatial
      mode = params[:mode] || :view
      render json: o.dwc_occurrence_attribute_values(mode)
    end
  end

  # GET /collection_objects/123/dwc_verbose
  def dwc_verbose
    o = nil
    ActiveRecord::Base.connection_pool.with_connection do
      o = CollectionObject.find(params[:id])

      if params[:rebuild] == 'true'
        # get does not rebuild
        o.set_dwc_occurrence
      else
        o.get_dwc_occurrence
      end
    end
    render json: o.dwc_occurrence_attributes
  end

  # Intent is DWC fields + quick summary fields for reports
  # !! As currently implemented rebuilds DWC all
  def report
    @collection_objects = ::Queries::CollectionObject::Filter.new(params).all.order('collection_objects.id').includes(:dwc_occurrence).page(params[:page]).per(params[:per] || 500)
  end

  # /collection_objects/preview?<filter params>
  def preview
    @collection_objects = ::Queries::CollectionObject::Filter.new(params).all.order('collection_objects.id').includes(:dwc_occurrence).page(params[:page]).per(params[:per] || 500)
  end

  # GET /collection_objects/depictions/1
  # GET /collection_objects/depictions/1.html
  # This is
  def depictions
  end

  def metadata_badge
  end

  # GET /collection_objects/1/inventory/images.html
  # GET /collection_objects/1/images.json
  def images
    @images = ::Queries::Image::Filter.new(
      collection_object_id: [ params.require(:id)],
      collection_object_scope: [:all]
    )

    respond_to do |format|
      format.html { @images = @images.all }
      format.json do  # rendered as Depictions for now
        @depictions = @iamges.derived_depictions
        render '/depictions/index' and return
      end
    end
  end

  # TODO: render in view
  # GET /collection_objects/1/geo_json
  # GET /collection_objects/1/geo_json.json
  def geo_json
    ce = @collection_object.collecting_event
    @geo_json = ce.nil? ? nil : ce.to_geo_json_feature
  end

  # GET /collection_objects/by_identifier/ABCD
  # TODO: remove for filter
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
      if @collection_object.destroyed?
        format.html { redirect_to after_destroy_path, notice: 'CollectionObject was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { destroy_redirect @collection_object, notice: 'CollectionObject was not destroyed, ' + @collection_object.errors.full_messages.join('; ') }
        format.json { render json: @collection_object.errors, status: :unprocessable_entity }
      end
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
      redirect_to collection_object_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to collection_object_path(params[:id])
    end
  end

  # GET /collection_objects/download
  def download
    send_data Export::CSV.generate_csv(CollectionObject.where(project_id: sessions_current_project_id), header_converters: []), type: 'text', filename: "collection_objects_#{DateTime.now}.tsv"
  end

  # GET collection_objects/batch_load
  def batch_load
  end

  def preview_simple_batch_load
    if params[:file]
      @result = BatchLoad::Import::CollectionObjects.new(**batch_params.merge(user_map))
      digest_cookie(params[:file].tempfile, :batch_collection_objects_md5)
      render 'collection_objects/batch_load/simple/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  def create_simple_batch_load
    if params[:file] && digested_cookie_exists?(
        params[:file].tempfile,
        :batch_collection_objects_md5)
      @result = BatchLoad::Import::CollectionObjects.new(**batch_params.merge(user_map))
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
      @result = BatchLoad::Import::CollectionObjects::CastorInterpreter.new(**batch_params)
      digest_cookie(params[:file].tempfile, :Castor_collection_objects_md5)
      render 'collection_objects/batch_load/castor/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  def create_castor_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :Castor_collection_objects_md5)
      @result = BatchLoad::Import::CollectionObjects::CastorInterpreter.new(**batch_params)
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
      @result = BatchLoad::Import::CollectionObjects::BufferedInterpreter.new(**batch_params)
      digest_cookie(params[:file].tempfile, :Buffered_collection_objects_md5)
      render 'collection_objects/batch_load/buffered/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  def create_buffered_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :Buffered_collection_objects_md5)
      @result = BatchLoad::Import::CollectionObjects::BufferedInterpreter.new(**batch_params)
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
    @collection_objects = CollectionObject.select_optimized(sessions_current_user_id, sessions_current_project_id, params[:target])
  end

  def autocomplete
    @collection_objects =
      ::Queries::CollectionObject::Autocomplete.new(
        params[:term],
        project_id: sessions_current_project_id
      ).autocomplete
  end

  # GET /api/v1/collection_objects
  def api_index
    @collection_objects = ::Queries::CollectionObject::Filter.new(params.merge!(api: true)).all
      .where(project_id: sessions_current_project_id)
      .order('collection_objects.id')
      .page(params[:page]).per(params[:per])
    render '/collection_objects/api/v1/index'
  end

  # GET /api/v1/collection_objects/:id
  def api_show
    render '/collection_objects/api/v1/show'
  end

  def api_autocomplete
    render json: {} and return if params[:term].blank?
    @collection_objects = ::Queries::CollectionObject::Autocomplete.new(params[:term], project_id: sessions_current_project_id).autocomplete
    render '/collection_objects/api/v1/autocomplete'
  end

  # GET /api/v1/collection_objects/123/dwc
  def api_dwc
    ActiveRecord::Base.connection_pool.with_connection do
      @collection_object.get_dwc_occurrence
      render json: @collection_object.dwc_occurrence_attributes
    end
  end

  # PATCH /collection_object/batch_update_dwc_occurrence.json?<collection object query params>
  def batch_update_dwc_occurrence
    if c = CollectionObject.batch_update_dwc_occurrence(params)
      render json: c.to_json, status: :ok
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  # PATCH /collection_object/batch_update.json?collection_object_query=<>&collection_object={}
  def batch_update
    if c = CollectionObject.batch_update(
        preview: params[:preview],
        collection_object: collection_object_params.merge(by: sessions_current_user_id),
        collection_object_query: params[:collection_object_query])
      render json: c.to_json, status: :ok
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  private

  def after_destroy_path
    if request.referer =~ /tasks\/collection_objects\/browse/
      if o = @collection_object.next_by_identifier
        browse_collection_objects_path(collection_object_id: o.id)
      else
        browse_collection_objects_path
      end
    else
      collection_objects_path
    end
  end

  def set_collection_object
    @collection_object = CollectionObject.with_project_id(sessions_current_project_id).find(params[:id])
    @recent_object = @collection_object
  end

  def collection_object_params
    params.require(:collection_object).permit(
      :total, :preparation_type_id, :repository_id, :current_repository_id,
      :ranged_lot_category_id, :collecting_event_id,
      :buffered_collecting_event, :buffered_determinations,
      :buffered_other_labels, :accessioned_at, :deaccessioned_at, :deaccession_reason,
      :contained_in,
      :taxon_determination_id,
      collecting_event_attributes: [],  # needs to be filled out!
      data_attributes_attributes: [ :id, :_destroy, :controlled_vocabulary_term_id, :type, :value ],
      tags_attributes: [:id, :_destroy, :keyword_id],
      depictions_attributes: [:id, :_destroy, :svg_clip, :svg_view_box, :position, :caption, :figure_label, :image_id],
      identifiers_attributes: [
        :id,
        :_destroy,
        :identifier,
        :namespace_id,
        :type,
        labels_attributes: [
          :text,
          :type,
          :text_method,
          :total
        ]
      ],
      taxon_determinations_attributes: [
        :id, :_destroy, :otu_id, :year_made, :month_made, :day_made, :position,
        roles_attributes: [:id, :_destroy, :type, :organization_id, :person_id, :position, person_attributes: [:last_name, :first_name, :suffix, :prefix]],
        otu_attributes: [:id, :_destroy, :name, :taxon_name_id]
      ],
      biocuration_classifications_attributes: [
        :id, :_destroy, :biocuration_class_id
      ]

    )
  end

  def batch_params
    params.permit(:file, :import_level, :source_id, :otu_id)
      .merge(user_id: sessions_current_user_id, project_id: sessions_current_project_id).to_h.symbolize_keys
  end

  # TODO: not used?
  def user_map
    {
      user_header_map: {
        'otu'         => 'otu_name',
        'start_day'   => 'start_date_day',
        'start_month' => 'start_date_month',
        'start_year'  => 'start_date_year',
        'end_day'     => 'end_date_day',
        'end_month'   => 'end_date_month',
        'end_year'    => 'end_date_year'}
    }
  end

  # An experiment to balance query/rendering times vs. extend[] requests
  # Likely suggests we need some fundamental changes.
  # @param CollectionObject::Filter.new() instance
  def add_includes_to_filter_result(collection_objects)
    a = %i(identifiers dwc_occurrence repository current_repository)

    x = []
    a.each do |e|
      if helpers.extend_response_with(e.to_s)
        x.push e
      end
    end

    if x.any?
      collection_objects = collection_objects.includes(*x)
    end

    if helpers.extend_response_with('collecting_event')
      collection_objects = collection_objects.includes(collecting_event: [:identifiers])
    end

    if helpers.extend_response_with('taxon_determinations')
      collection_objects = collection_objects.includes(taxon_determinations: [:otu, roles: [:person]])
    end

    collection_objects
  end

end

require_dependency Rails.root.to_s + '/lib/batch_load/import/collection_objects/castor_interpreter.rb'
