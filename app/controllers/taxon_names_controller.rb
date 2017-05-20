class TaxonNamesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_taxon_name, only: [:show, :edit, :update, :destroy, :browse]

  # GET /taxon_names
  # GET /taxon_names.json
  def index
    @recent_objects = TaxonName.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
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
    @taxon_name.source = Source.new if !@taxon_name.source
  end

  # POST /taxon_names
  # POST /taxon_names.json
  def create
    @taxon_name = TaxonName.new(taxon_name_params)

    respond_to do |format|
      if @taxon_name.save
        format.html { redirect_to @taxon_name.metamorphosize,
                                  notice: "Taxon name '#{@taxon_name.name}' was successfully created." }
        format.json { render action: 'show', status: :created, location: @taxon_name }
      else
        format.html { render action: 'new' }
        format.json { render json: @taxon_name.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxon_names/1
  # PATCH/PUT /taxon_names/1.json
  def update
    respond_to do |format|
      if @taxon_name.update(taxon_name_params)
        format.html { redirect_to @taxon_name.metamorphosize, notice: 'Taxon name was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @taxon_name.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxon_names/1
  # DELETE /taxon_names/1.json
  def destroy
    @taxon_name.destroy
    respond_to do |format|
      format.html { redirect_to taxon_names_url }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to taxon_names_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to taxon_name_path(params[:id])
    end
  end

  def autocomplete
    render json: {} and return if params[:term].blank?
    @taxon_names = Queries::TaxonNameAutocompleteQuery.new(
      params[:term],
      autocomplete_params.to_h
    ).all

    data = @taxon_names.collect do |t|
      str = render_to_string(partial: 'autocomplete_tag', locals: {taxon_name: t, term: params[:term] })
      {id:              t.id,
       label:           ApplicationController.helpers.taxon_name_autocomplete_selected_tag(t),
       response_values: {
         params[:method] => t.id
       },
       label_html:       str
      }
    end

    render :json => data
  end

  def autocomplete_params
    params.permit(:valid, type: [], parent_id: [], nomenclature_group: []).symbolize_keys.merge(project_id: sessions_current_project_id)
  end

  def list
    @taxon_names = TaxonName.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) 
  end

  # GET /taxon_names/download
  def download
    send_data Download.generate_csv(
      TaxonName.where(project_id: sessions_current_project_id)
    ), type: 'text', filename: "taxon_names_#{DateTime.now.to_s}.csv"
  end

  def batch_load
  end

  def preview_simple_batch_load 
    if params[:file] 
      @result =  BatchLoad::Import::TaxonifiToTaxonworks.new(batch_params)
      digest_cookie(params[:file].tempfile, :simple_taxon_names_md5)
      render 'taxon_names/batch_load/simple/preview'
    else
      flash[:notice] = "No file provided!"
      redirect_to action: :batch_load 
    end
  end

  def create_simple_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :simple_taxon_names_md5)
      @result =  BatchLoad::Import::TaxonifiToTaxonworks.new(batch_params)
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

  private

  def set_taxon_name 
    @taxon_name = TaxonName.with_project_id(sessions_current_project_id).includes(:creator, :updater).find(params[:id]) 
    @recent_object = @taxon_name
  end

  def taxon_name_params
    params.require(:taxon_name).permit(
      :name, 
      :parent_id, 
      :year_of_publication,
      :verbatim_author, :rank_class, :type, :masculine_name,
      :feminine_name, :neuter_name, :also_create_otu,
      roles_attributes: [
        :id, :_destroy, :type, :person_id, :position, 
        person_attributes: [
          :last_name, :first_name, :suffix, :prefix
        ]
      ],
      origin_citation_attributes: [:id, :_destroy, :source_id] 
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
      ).symbolize_keys
  end

end
