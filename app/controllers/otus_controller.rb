class OtusController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_otu, only: [
    :show, :edit, :update, :destroy, :collection_objects, :navigation,
    :breadcrumbs, :timeline, :coordinate, :distribution,
    :api_show, :api_taxonomy_inventory, :api_type_material_inventory,
    :api_nomenclature_citations, :api_distribution, :api_content, :api_dwc_inventory, :api_dwc_gallery, :api_key_inventory ]

  after_action -> { set_pagination_headers(:otus) }, only: [:index, :api_index], if: :json_request?

  # GET /otus
  # GET /otus.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Otu.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @otus = ::Queries::Otu::Filter.new(params).all
          .page(params[:page])
          .per(params[:per])
          .eager_load(:taxon_name)
          .order(:cached, 'otus.name')
      }
    end
  end

  # GET /otus/1
  # GET /otus/1.json
  def show
  end

  # GET /otus/new
  def new
    @otu = Otu.new
  end

  # GET /otus/1/edit
  def edit
  end

  def list
    @otus = Otu.with_project_id(sessions_current_project_id).page(params[:page]).per(params[:per])
  end

  # GET /otus/1/timeline.json
  def timeline
    @catalog = Catalog::Timeline.new(targets: [@otu])
  end

  # GET /otus/1/navigation.json
  def navigation
  end

  # GET /otus/1/coordinate.json
  def coordinate
    @otus = Otu.coordinate_otus(@otu.id)
    render :index
  end

  # GET /otus/1/navigation.json
  def breadcrumbs
    render json: :not_found and return if @otu.nil?
  end

  # POST /otus
  # POST /otus.json
  def create
    @otu = Otu.new(otu_params)

    respond_to do |format|
      if @otu.save
        format.html { redirect_to @otu,
                      notice: "Otu '#{@otu.name}' was successfully created." }
        format.json { render action: :show, status: :created, location: @otu }
      else
        format.html { render action: 'new' }
        format.json { render json: @otu.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /otus/1
  # PATCH/PUT /otus/1.json
  def update
    respond_to do |format|
      if @otu.update(otu_params)
        format.html { redirect_to @otu, notice: 'Otu was successfully updated.' }
        format.json { render :show, location: @otu }
      else
        format.html { render action: 'edit' }
        format.json { render json: @otu.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /otus/1
  # DELETE /otus/1.json
  def destroy
    @otu.destroy
    respond_to do |format|
      if @otu.destroyed?
        format.html { destroy_redirect @otu, notice: 'OTU was successfully destroyed.' }
        format.json { head :no_content}
      else
        format.html { destroy_redirect @otu, notice: 'OTU was not destroyed, ' + @otu.errors.full_messages.join('; ') }
        format.json { render json: @otu.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /otus/1/collection_objects
  def collection_objects
    @collection_objects = Otu.where(project_id: sessions_current_project_id).find(params[:id]).collection_objects.pluck(:id)
  end

  def search
    if params[:id].blank?
      redirect_to(otus_path,
                  alert: 'You must select an item from the list with a click or tab press before clicking show.')
    else
      redirect_to otu_path(params[:id])
    end
  end

  def batch_load
    # see app/views/otus/batch_load.html.erb
  end

  def preview_simple_batch_load
    if params[:file]
      @result = BatchLoad::Import::Otus.new(**batch_params.merge(user_map))
      digest_cookie(params[:file].tempfile, :batch_otus_md5)
      render('otus/batch_load/simple/preview')
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  def create_simple_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :batch_otus_md5)
      @result = BatchLoad::Import::Otus.new(**batch_params.merge(user_map))
      if @result.create
        flash[:notice] = "Successfully processed file, #{@result.total_records_created} otus were created."
        render('otus/batch_load/simple/create') and return
      else
        flash[:alert] = 'Batch import failed.'
      end
      render(:batch_load)
    end
  end

  def preview_identifiers_batch_load
    if params[:file]
      @result = BatchLoad::Import::Otus::IdentifiersInterpreter.new(**batch_params)
      digest_cookie(params[:file].tempfile, :batch_load_otus_identifiers_md5)
      render('otus/batch_load/identifiers/preview')
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  def create_identifiers_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :batch_load_otus_identifiers_md5)
      @result = BatchLoad::Import::Otus::IdentifiersInterpreter.new(**batch_params)
      if @result.create
        flash[:notice] = "Successfully processed file, #{@result.total_records_created} otus were created."
        render('otus/batch_load/identifiers/create')
        return
      else
        flash[:alert] = 'Batch import failed.'
      end
      render(:batch_load)
    end
  end

  def preview_simple_batch_file_load
    if params[:files]
      @result = BatchFileLoad::Import::Otus::SimpleInterpreter.new(**batch_params)
      digest_cookie(params[:files][0].tempfile, :batch_file_load_simple_md5)
      render 'otus/batch_file_load/simple/preview'
    else
      flash[:notice] = 'No file(s) provided!'
      redirect_to action: :batch_load
    end
  end

  def create_simple_batch_file_load
    if params[:files] && digested_cookie_exists?(params[:files][0].tempfile, :batch_file_load_simple_md5)
      @result = BatchFileLoad::Import::Otus::SimpleInterpreter.new(**batch_params)

      if @result.create
        flash[:notice] = "Successfully processed #{@result.total_files_processed} file(s), #{@result.total_records_created} otus were created."
        render 'otus/batch_file_load/simple/create'
        return
      else
        flash[:alert] = 'Batch import failed.'
        render :batch_load
      end
    end
  end

  # TODO: AUTOGENERATED STUB, check and update
  def preview_data_attributes_batch_load
    if params[:file]
      @result = BatchLoad::Import::Otus::DataAttributesInterpreter.new(**batch_params)
      digest_cookie(params[:file].tempfile, :data_attributes_batch_load_otus_md5)
      render 'otus/batch_load/data_attributes/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  # TODO: AUTOGENERATED STUB, check and update
  def create_data_attributes_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :data_attributes_batch_load_otus_md5)
      @result = BatchLoad::Import::Otus::DataAttributesInterpreter.new(**batch_params)
      if @result.create
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} TODO RECORD TYPES were created."
        render 'otus/batch_load/data_attributes/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :batch_load
  end

  # GET /otus/download
  def download
    send_data Export::CSV.generate_csv(Otu.where(project_id: sessions_current_project_id)),
      type: 'text',
      filename: "otus_#{DateTime.now}.tsv"
  end

  # GET api/v1/otus/by_name/:name?token=:token&project_id=:id
  def by_name
    @otu_name = params.require(:name)
    @otu_ids = ::Queries::Otu::Autocomplete.new(@otu_name, project_id: params.require(:project_id)).all.pluck(:id)
  end

  # GET /otus/select_options?target=TaxonDetermination
  def select_options
    @otus = Otu.select_optimized(sessions_current_user_id, sessions_current_project_id, params.require(:target))
  end

  # PATCH /otus/batch_update.json?otus_query=<>&otu={taxon_name_id=123}}
  def batch_update
    if r = Otu.batch_update(
        preview: params[:preview],
        otu: otu_params.merge(by: sessions_current_user_id),
        otu_query: params[:otu_query],
    )
      render json: r.to_json, status: :ok
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  # GET /api/v1/otus.csv
  # GET /api/v1/otus
  def api_index
    q = ::Queries::Otu::Filter.new(params.merge!(api: true)).all
      .where(project_id: sessions_current_project_id)
      .order('otus.id')

    respond_to do |format|
      format.json {
        @otus = q.page(params[:page]).per(params[:per])
        render '/otus/api/v1/index'
      }
      format.csv {
        @otus = q
        send_data Export::CSV.generate_csv(
          @otus,
          exclude_columns: %w{updated_by_id created_by_id project_id},
        ), type: 'text', filename: "otus_#{DateTime.now}.tsv"
      }
    end
  end

  # GET /api/v1/otus/:id
  def api_show
    render '/otus/api/v1/show'
  end

  def autocomplete
    @otus = ::Queries::Otu::Autocomplete.new(
      params.require(:term),
      exact: 'true',
      project_id: sessions_current_project_id,
      with_taxon_name: params[:with_taxon_name],
      having_taxon_name_only: params[:having_taxon_name_only],
    ).autocomplete
  end

  # GET /api/v1/otus/autocomplete
  def api_autocomplete
    @otu_metadata = ::Queries::Otu::Autocomplete.new(
      params.require(:term),
      project_id: sessions_current_project_id,
      with_taxon_name: params[:with_taxon_name],
      having_taxon_name_only: params[:having_taxon_name_only]
    ).api_autocomplete_extended


    render '/otus/api/v1/autocomplete'
  end

  # GET /api/v1/otus/:id/inventory/images
  #  - routed here to take advantage of Pagination
  def api_image_inventory
    @depictions = ::Queries::Depiction::Filter.new(
      project_id: sessions_current_project_id,
      otu_id: [params.require(:otu_id)],
      otu_scope: (params[:otu_scope] || :all)
    ).all
     .joins("LEFT OUTER JOIN observations ON (observations.id = depictions.depiction_object_id and depictions.depiction_object_type = 'Observation')")
     .joins('LEFT OUTER JOIN descriptors ON descriptors.id = observations.descriptor_id')
     .joins('LEFT OUTER JOIN observation_matrix_column_items ON descriptors.id = observation_matrix_column_items.descriptor_id')
     .eager_load(image: [:attribution])
    if params[:sort_order]
      @depictions = @depictions.order( Arel.sql( conditional_sort('depictions.depiction_object_type', params[:sort_order]) + ", observation_matrix_column_items.position, depictions.depiction_object_id, depictions.position" ))
    else
      @depictions = @depictions.order("depictions.depiction_object_type, observation_matrix_column_items.position, depictions.depiction_object_id, depictions.position")
    end
    @depictions = @depictions.page(params[:page]).per(params[:per])

    render '/otus/api/v1/inventory/images'
  end

  # GET /api/v1/otus/:id/inventory/keys
  def api_key_inventory
    render json: helpers.otu_key_inventory(@otu)
  end

  # GET /api/v1/otus/:id/inventory/taxonomy
  def api_taxonomy_inventory
    render '/otus/api/v1/inventory/taxonomy'
  end

  # GET /api/v1/otus/:id/inventory/dwc
  def api_dwc_inventory
    respond_to do |format|
      format.csv do
        send_data Export::CSV.generate_csv(
          DwcOccurrence.scoped_by_otu(@otu),
          exclude_columns: ['id', 'created_by_id', 'updated_by_id', 'project_id', 'updated_at']),
        type: 'text',
        filename: "dwc_#{helpers.label_for_otu(@otu).gsub(/\W/,'_')}_#{DateTime.now}.csv"
      end

      format.json do
        if params[:page].blank? && params[:per].blank?
          render json: DwcOccurrence.scoped_by_otu(@otu).to_json
        else # only apply if provided, do not fall back to default scope
          r = DwcOccurrence.scoped_by_otu(@otu).page(params[:page]).per(params[:per])
          assign_pagination(r)
          render json: r.to_json
        end
      end
    end
  end

  # GET /api/v1/otus/:id/inventory/dwc_gallery.json?per=1&page=2
  def api_dwc_gallery
    # see otus_helper

    @data = helpers.dwc_gallery_data(@otu, dwc_occurrence_id: params[:dwc_occurrence_id])
    render '/otus/api/v1/inventory/dwc_gallery'
  end

  # GET /api/v1/otus/:id/inventory/content
  def api_content
    topic_ids = [params[:topic_id]].flatten.compact.uniq

    @public_content =  PublicContent.where(otu: @otu, project_id: sessions_current_project_id)
    @public_content = @public_content.joins(:topic).where(topic_id: topic_ids) unless topic_ids.empty?

    render '/otus/api/v1/inventory/content'
  end

  # GET /api/v1/otus/:id/inventory/type_material
  def api_type_material_inventory
    render '/otus/api/v1/inventory/type_material'
  end

  # GET /api/v1/otus/:id/inventory/nomenclature_citations
  def api_nomenclature_citations
    if @otu.taxon_name
      @data = ::Catalog::Nomenclature::Entry.new(@otu.taxon_name)
      render '/otus/api/v1/inventory/nomenclature_citations'
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  # TODO: Redirect to json if too big?
  # GET /otus/:id/inventory/distribution.json
  # GET /otus/:id/inventory/distribution.geojson
  def distribution
    respond_to do |format|
      format.json do
        @cached_map_type = params[:cached_map_type] || 'CachedMapItem::WebLevel1'
        @quicker_cached_map = @otu.quicker_cached_map(@cached_map_type)

        render json: { error: 'no map available'}, status: :not_found unless @quicker_cached_map.present? and return
      end

      format.geojson do
      end
    end
  end

  # TODO: Considerations
  # .json
  #   * Scope Genus, Family by default
  #   *
  #   * 404 when no CachedMap computable
  #
  # .geo_json
  #   * Always returns result, could be empty
  #
  #
  # GET /api/v1/otus/:id/inventory/distribution.json
  # GET /api/v1/otus/:id/inventory/distribution.geojson
  def api_distribution
    respond_to do |format|
      format.json do
        @cached_map_type = params[:cached_map_type] || 'CachedMapItem::WebLevel1'
        @quicker_cached_map = @otu.quicker_cached_map(@cached_map_type)
        if @quicker_cached_map.blank?
          render json: { error: 'no map available'}, status: :not_found and return
        end
        render '/otus/api/v1/inventory/distribution'
      end
      format.geojson do
        render '/otus/api/v1/inventory/distribution'
      end
    end

  end

  private

  def set_otu
    @otu = Otu.where(project_id: sessions_current_project_id).eager_load(:taxon_name).find(params[:id])
    @recent_object = @otu
  end

  # def set_cached_map
  #   @cached_map = @otu.cached_maps.where(cached_map_type: params[:cached_map_type] || 'CachedMapItem::WebLevel1').first
  #   if @cached_map.blank?

  #   end
  # end

  def otu_params
    params.require(:otu).permit(:name, :taxon_name_id, :exact)
  end

  def batch_params
    params.permit(
      :name, :file, :import_level,
      :create_new_otu, :source_id, :type_select, :create_new_predicate,
      files: [])
      .merge(
        user_id: sessions_current_user_id,
        project_id: sessions_current_project_id)
      .to_h
      .symbolize_keys
  end

  def user_map
    {user_header_map: {'otu' => 'otu_name'}}
  end

  # TODO: Move to generic toolkit  in lib/queries
  def conditional_sort(name, array)
    s = "CASE #{name} " + array.each_with_index.collect{|v,i|
      ApplicationRecord.sanitize_sql_for_conditions(["WHEN ? THEN #{i}", v])}.join(' ')
    s << ' ELSE 999999 END'
    s
  end

end
