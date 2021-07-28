class AssertedDistributionsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_asserted_distribution, only: [:show, :edit, :update, :destroy, :api_show]

  # GET /asserted_distributions
  # GET /asserted_distributions.json
  def index
    respond_to do |format|
      format.html {
        @recent_objects = AssertedDistribution.recent_from_project_id(sessions_current_project_id)
          .order(updated_at: :desc)
          .limit(10)
        render '/shared/data/all/index'
      }
      format.json {
        @asserted_distributions = Queries::AssertedDistribution::Filter.new(filter_params)
          .all
          .where(project_id: sessions_current_project_id)
          .page(params[:page])
          .per(params[:per] || 500)
      }
    end
  end

  # GET /asserted_distributions/1
  # GET /asserted_distributions/1.json
  def show
    # @asserted_distribution = AssertedDistribution.find(params[:id])
  end

  # GET /asserted_distributions/new
  def new
    @asserted_distribution = AssertedDistribution.new(origin_citation: Citation.new)
  end

  # GET /asserted_distributions/1/edit
  def edit
    @asserted_distribution.source = Source.new if !@asserted_distribution.source
  end

  # POST /asserted_distributions
  # POST /asserted_distributions.json
  def create
    @asserted_distribution = AssertedDistribution.new(asserted_distribution_params)
    respond_to do |format|
      if @asserted_distribution.save
        format.html { redirect_to @asserted_distribution, notice: 'Asserted distribution was successfully created.' }
        format.json { render :show, status: :created, location: @asserted_distribution }
      else
        format.html { render :new }
        format.json { render json: @asserted_distribution.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /asserted_distributions/1
  # PATCH/PUT /asserted_distributions/1.json
  def update
    respond_to do |format|
      if @asserted_distribution.update(asserted_distribution_params)
        format.html { redirect_to @asserted_distribution, notice: 'Asserted distribution was successfully updated.' }
        format.json { render :show, status: :ok, location: @asserted_distribution }
      else
        format.html { render :edit }
        format.json { render json: @asserted_distribution.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /asserted_distributions/1
  # DELETE /asserted_distributions/1.json
  def destroy
    @asserted_distribution.mark_citations_for_destruction
    @asserted_distribution.destroy!

    respond_to do |format|
      format.html { redirect_to asserted_distributions_url, notice: 'Asserted distribution was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @asserted_distributions = AssertedDistribution.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  def autocomplete
    @asserted_distributions = Queries::AssertedDistribution::Autocomplete.new(params.require(:term), project_id: sessions_current_project_id).autocomplete
  end

  # TODO: deprecate
  def search
    if params[:id].blank?
      redirect_to asserted_distributions_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to asserted_distribution_path(params[:id])
    end
  end

  # GET /asserted_distributions/download
  def download
    send_data(
      Export::Download.generate_csv(AssertedDistribution.where(project_id: sessions_current_project_id)),
      type: 'text',
      filename: "asserted_distributions_#{DateTime.now}.csv")
  end

  # GET /asserted_distributions/batch_load
  def batch_load
  end

  def preview_simple_batch_load
    if params[:file]
      @result =  BatchLoad::Import::AssertedDistributions.new(**batch_params)
      digest_cookie(params[:file].tempfile, :batch_asserted_distributions_md5)
      render 'asserted_distributions/batch_load/simple/preview'
    else
      flash[:notice] = 'No file provided!'
      redirect_to action: :batch_load
    end
  end

  def create_simple_batch_load
    if params[:file] && digested_cookie_exists?(params[:file].tempfile, :batch_asserted_distributions_md5)
      @result =  BatchLoad::Import::AssertedDistributions.new(**batch_params)
      if @result.create
        flash[:notice] = "Successfully proccessed file, #{@result.total_records_created} asserted distributions were created."
        render 'asserted_distributions/batch_load/simple/create' and return
      else
        flash[:alert] = 'Batch import failed.'
      end
    else
      flash[:alert] = 'File to batch upload must be supplied.'
    end
    render :batch_load
  end

  def api_index
    @asserted_distributions = Queries::AssertedDistribution::Filter.new(api_params)
      .all
      .where(project_id: sessions_current_project_id)
      .order('asserted_distributions.id')
      .page(params[:page])
      .per(params[:per] || 100)
    render '/asserted_distributions/api/v1/index'
  end

  def api_show
    render '/asserted_distributions/api/v1/show'
  end

  private

  def set_asserted_distribution
    @asserted_distribution = AssertedDistribution.where(project_id: sessions_current_project_id).find(params[:id])
    @recent_object = @asserted_distribution
  end

  def asserted_distribution_params
    params.require(:asserted_distribution).permit(
      :otu_id,
      :geographic_area_id,
      :is_absent,
      otu_attributes: [:id, :_destroy, :name, :taxon_name_id],
      origin_citation_attributes: [:id, :_destroy, :source_id, :pages],
      citations_attributes: [:id, :is_original, :_destroy, :source_id, :pages, :citation_object_id, :citation_object_type],
      data_attributes_attributes: [ :id, :_destroy, :controlled_vocabulary_term_id, :type, :attribute_subject_id, :attribute_subject_type, :value ]
    )
  end

  def batch_params
    params.permit(:data_origin, :file, :import_level).merge(user_id: sessions_current_user_id, project_id: sessions_current_project_id).to_h.symbolize_keys
  end

  def filter_params
    params.permit(:otu_id, :geographic_area_id, :recent, otu_id: [], geographic_area_id: [])
  end

  def api_params
    params.permit(:otu_id, :geographic_area_id, :recent, :geo_json)
  end


end
