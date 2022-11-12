class OtusController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_otu, only: [
    :show, :edit, :update, :destroy, :collection_objects, :navigation,
    :breadcrumbs, :timeline, :coordinate,
    :api_show, :api_taxonomy_inventory, :api_type_material_inventory, :api_nomenclature_citations, :api_distribution, :api_content ]
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
        @otus = ::Queries::Otu::Filter.new(filter_params).all.where(project_id: sessions_current_project_id).page(params[:page]).per(params[:per] || 50)
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

  def autocomplete
    @otus = Queries::Otu::Autocomplete.new(params.require(:term), project_id: sessions_current_project_id).autocomplete
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
      flash[:notice] = "No file provided!"
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
    send_data Export::Download.generate_csv(Otu.where(project_id: sessions_current_project_id)),
      type: 'text',
      filename: "otus_#{DateTime.now}.csv"
  end

  # GET api/v1/otus/by_name/:name?token=:token&project_id=:id
  def by_name
    @otu_name = params.require(:name)
    @otu_ids = Queries::Otu::Autocomplete.new(@otu_name, project_id: params.require(:project_id)).all.pluck(:id)
  end

  # GET /otus/select_options?target=TaxonDetermination
  def select_options
    @otus = Otu.select_optimized(sessions_current_user_id, sessions_current_project_id, params.require(:target))
  end

  # GET /api/v1/otus
  def api_index
    @otus = Queries::Otu::Filter.new(api_params).all
      .where(project_id: sessions_current_project_id)
      .order('otus.id')
      .page(params[:page]).per(params[:per])
    render '/otus/api/v1/index'
  end

  # GET /api/v1/otus/:id
  def api_show
    render '/otus/api/v1/show'
  end

  def api_autocomplete
    @otus = Queries::Otu::Autocomplete.new(
      params.require(:term),
      project_id: sessions_current_project_id,
      having_taxon_name_only: params[:having_taxon_name_only]
    ).autocomplete
    render '/otus/api/v1/autocomplete'
  end

  # GET /api/v1/otus/:id/inventory/taxonomy
  def api_taxonomy_inventory
    render '/otus/api/v1/inventory/taxonomy'
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

  # GET /api/v1/otus/:id/inventory/distribution
  def api_distribution
    render '/otus/api/v1/distribution'
  end

  private

  def set_otu
    @otu = Otu.where(project_id: sessions_current_project_id).find(params[:id])
    @recent_object = @otu
  end

  def otu_params
    params.require(:otu).permit(:name, :taxon_name_id)
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

  def filter_params
    params.permit(
      :name,
      :name_exact,

      :otu_id,
      :taxon_name_id,
      :collecting_event_id,
      :wkt,

      collecting_event_id: [],
      otu_id: [],
      taxon_name_id: [],
      name: []

    # :asserted_distributions,
    # :biological_associations,
    # :citations,
    # :contents,
    # :depictions,
    # :exact_author,

    # :taxon_determinations,
    # :observations,
    # :author,
    # biological_association_ids: [],
    # taxon_name_ids: [],
    # otu_ids: [],
    # taxon_name_relationship_ids: [],
    # taxon_name_classification_ids: [],
    # asserted_distribution_ids: [],



    # data_attributes_attributes: [ :id, :_destroy, :controlled_vocabulary_term_id, :type, :attribute_subject_id, :attribute_subject_type, :value ]
    )
  end

  def api_params
    params.permit(
      :name,
      :taxon_name_id, :otu_id,
      biological_association_ids: [], taxon_name_ids: [], otu_ids: [],
      taxon_name_relationship_ids: [],taxon_name_classification_ids: [],
      asserted_distribution_ids: [],
      data_attributes_attributes: [ :id, :_destroy, :controlled_vocabulary_term_id, :type, :attribute_subject_id, :attribute_subject_type, :value ]
    )
  end

  def user_map
    {user_header_map: {'otu' => 'otu_name'}}
  end

end
