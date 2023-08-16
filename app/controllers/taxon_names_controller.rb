class TaxonNamesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_taxon_name, only: [:show, :edit, :update, :destroy, :browse, :original_combination, :catalog, :api_show, :api_summary, :api_catalog]
  after_action -> { set_pagination_headers(:taxon_names) }, only: [:index, :api_index], if: :json_request?

  # GET /taxon_names
  # GET /taxon_names.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = TaxonName.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @taxon_names = ::Queries::TaxonName::Filter.new(params).all
        .page(params[:page])
        .per(params[:per])
      }
    end
  end

  # GET /taxon_names/1
  # GET /taxon_names/1.json
  def show
  end

  # GET /taxon_names/new
  def new
    @taxon_name = Protonym.new(source: Source.new)
  end

  # GET /taxon_names/1/edit
  def edit
  end

  # POST /taxon_names
  # POST /taxon_names.json
  def create
    @taxon_name = TaxonName.new(taxon_name_params)
    respond_to do |format|
      if @taxon_name.save
        format.html { redirect_to url_for(@taxon_name.metamorphosize),
                      notice: "Taxon name '#{@taxon_name.name}' was successfully created." }
        format.json { render :show, status: :created, location: @taxon_name.metamorphosize }
      else
        format.html { render action: :new }
        format.json { render json: @taxon_name.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxon_names/1
  # PATCH/PUT /taxon_names/1.json
  def update
    respond_to do |format|
      if @taxon_name.update(taxon_name_params)

        # TODO: WHY?!
        @taxon_name.reload

        format.html { redirect_to url_for(@taxon_name.metamorphosize), notice: 'Taxon name was successfully updated.' }
        format.json { render :show, status: :ok, location: @taxon_name.metamorphosize }
      else
        format.html { render action: :edit }
        format.json { render json: @taxon_name.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxon_names/1
  # DELETE /taxon_names/1.json
  def destroy
    @taxon_name.destroy
    respond_to do |format|
      if @taxon_name.destroyed?
        format.html { destroy_redirect @taxon_name, notice: 'TaxonName was successfully destroyed.' }
        format.json { head :no_content }
      else
        format.html { destroy_redirect @taxon_name, notice: 'TaxonName was not destroyed, ' + @taxon_name.errors.full_messages.join('; ') }
        format.json { render json: @taxon_name.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    if params[:id].blank?
      redirect_to taxon_names_path, alert: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to taxon_name_path(params[:id])
    end
  end

  def autocomplete
    render json: {} and return if params[:term].blank?
    @taxon_names = ::Queries::TaxonName::Autocomplete.new(
      params[:term],
      **autocomplete_params
    ).autocomplete
  end

  def list
    @taxon_names = TaxonName.with_project_id(sessions_current_project_id).order(:id).page(params[:page])
  end

  # GET /taxon_names/download
  def download
    send_data Export::Download.generate_csv(
      TaxonName.where(project_id: sessions_current_project_id)
    ), type: 'text', filename: "taxon_names_#{DateTime.now}.csv"
  end

  def batch_load
  end

  def ranks
    render json: RANKS_JSON.to_json
  end

  def predicted_rank
    if params[:parent_id]
      p = TaxonName.find_by(id: params[:parent_id])
      if p.nil?
        render json: {predicted_rank: ''}.to_json
      else
        render json: {predicted_rank: p.predicted_child_rank(params[:name]).to_s}.to_json
      end
    else
      render json: {predicted_rank: ''}.to_json
    end
  end

  def random
    redirect_to browse_nomenclature_task_path(
      taxon_name_id: TaxonName.where(project_id: sessions_current_project_id).order('random()').limit(1).pluck(:id).first
    )
  end

  def rank_table
    @query = ::Queries::TaxonName::Tabular.new(
      ancestor_id: params.require(:ancestor_id),
      ranks: params.require(:ranks),
      fieldsets: params[:fieldsets],
      limit: params[:limit],
      validity: params[:validity],
      combinations: params[:combinations],
      project_id: sessions_current_project_id,
      rank_data: params[:rank_data]
    )
  end

  # GET /taxon_names/select_options
  def select_options
    @taxon_names = TaxonName.select_optimized(
      sessions_current_user_id,
      sessions_current_project_id,
      target: params[:target]
    )
  end

  def preview_simple_batch_load
    if params[:file]
      @result = BatchLoad::Import::TaxonifiToTaxonworks.new(**batch_params)
      digest_cookie(params[:file].tempfile, :simple_taxon_names_md5)
      render 'taxon_names/batch_load/simple/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  def create_simple_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :simple_taxon_names_md5)
      @result =  BatchLoad::Import::TaxonifiToTaxonworks.new(**batch_params)
      if @result.create
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} taxon names were created."
        render 'taxon_names/batch_load/simple/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :batch_load
  end

  def preview_nomen_batch_load
    if params[:file]
      @result = BatchLoad::Import::TaxonNames::NomenInterpreter.new(**batch_params)
      digest_cookie(params[:file].tempfile, :nomen_taxon_names_md5)
      render 'taxon_names/batch_load/nomen/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  def create_nomen_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :nomen_taxon_names_md5)
      @result = BatchLoad::Import::TaxonNames::NomenInterpreter.new(**batch_params)
      if @result.create
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} items were created."
        render 'taxon_names/batch_load/nomen/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :batch_load
  end

  def parse
    @combination = Combination.where(project_id: sessions_current_project_id).find(params[:combination_id]) if params[:combination_id]
    @result = TaxonWorks::Vendor::Biodiversity::Result.new(
      query_string: params.require(:query_string),
      project_id: sessions_current_project_id,
      code: :iczn # !! TODO: generalize
    ).result
  end

  # GET /taxon_names/1/original_combination
  def original_combination
  end

  # GET /api/v1/taxon_names
  def api_index
    @taxon_names = ::Queries::TaxonName::Filter.new(params.merge!(api: true)).all
      .where(project_id: sessions_current_project_id)
      .order('taxon_names.id')
      .page(params[:page])
      .per(params[:per])
    render '/taxon_names/api/v1/index'
  end

  # GET /api/v1/taxon_names/:id
  def api_show
    render '/taxon_names/api/v1/show'
  end

  # GET /api/v1/taxon_names/:id/inventory/summary
  def api_summary
    render '/taxon_names/api/v1/summary'
  end

  # GET /api/v1/taxon_names/:id/inventory/catalog
  def api_catalog
    @data = helpers.recursive_catalog_json(taxon_name: @taxon_name, target_depth: params[:target_depth] || 0 )
    render '/taxon_names/api/v1/catalog'
  end

  def api_parse
    @combination = Combination.where(project_id: sessions_current_project_id).find(params[:combination_id]) if params[:combination_id]
    @result = TaxonWorks::Vendor::Biodiversity::Result.new(
      query_string: params.require(:query_string),
      project_id: sessions_current_project_id,
      code: :iczn # !! TODO: generalize
    ).result
    render '/taxon_names/api/v1/parse'
  end

  private

  def set_taxon_name
    @taxon_name = TaxonName.with_project_id(sessions_current_project_id).includes(:creator, :updater).find(params[:id])
    @recent_object = @taxon_name
  end

  def autocomplete_params
    params.permit(
      :valid, :exact, :no_leaves,
      type: [], parent_id: [], nomenclature_group: []
    ).to_h.symbolize_keys.merge(project_id: sessions_current_project_id)
  end

  def taxon_name_params
    params.require(:taxon_name).permit(
      :name,
      :parent_id,
      :year_of_publication,
      :etymology,
      :verbatim_author, :verbatim_name, :rank_class, :type, :masculine_name,
      :feminine_name, :neuter_name, :also_create_otu,
      roles_attributes: [
        :id, :_destroy, :type, :person_id, :position,
        person_attributes: [
          :last_name, :first_name, :suffix, :prefix
        ]
      ],
      family_group_name_form_relationship_attributes: [:id, :_destroy, :object_taxon_name_id],
      origin_citation_attributes: [:id, :_destroy, :source_id, :pages],
      taxon_name_classifications_attributes: [:id, :_destroy, :type]
    )
  end

  def batch_params
    params.permit(
      :file,
      :parent_taxon_name_id,
      :nomenclature_code,
      :also_create_otu,
      :import_level).merge(
        user_id: sessions_current_user_id,
        project_id: sessions_current_project_id
      ).to_h.symbolize_keys
  end

end

require_dependency Rails.root.to_s + '/lib/batch_load/import/taxon_names/nomen_interpreter.rb'
