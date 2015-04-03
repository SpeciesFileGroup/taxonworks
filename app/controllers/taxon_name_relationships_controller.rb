class TaxonNameRelationshipsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_taxon_name_relationship, only: [:show, :edit, :update, :destroy]

  # GET /taxon_name_relationships
  # GET /taxon_name_relationships.json
  def index
    @recent_objects = TaxonNameRelationship.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /taxon_name_relationships/1
  # GET /taxon_name_relationships/1.json
  def show
  end

  # GET /taxon_name_relationships/new
  def new
    @taxon_name_relationship = TaxonNameRelationship.new
  end

  # GET /taxon_name_relationships/1/edit
  def edit
  end

  # POST /taxon_name_relationships
  # POST /taxon_name_relationships.json
  def create
    @taxon_name_relationship = TaxonNameRelationship.new(taxon_name_relationship_params)

    respond_to do |format|
      if @taxon_name_relationship.save
        format.html { redirect_to @taxon_name_relationship.metamorphosize, notice: 'Taxon name relationship was successfully created.' }
        format.json { render action: 'show', status: :created, location: @taxon_name_relationship.metamorphosize }
      else
        format.html { render action: 'new' }
        format.json { render json: @taxon_name_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxon_name_relationships/1
  # PATCH/PUT /taxon_name_relationships/1.json
  def update
    respond_to do |format|
      if @taxon_name_relationship.update(taxon_name_relationship_params)
        format.html { redirect_to @taxon_name_relationship.metamorphosize, notice: 'Taxon name relationship was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @taxon_name_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxon_name_relationships/1
  # DELETE /taxon_name_relationships/1.json
  def destroy
    @taxon_name_relationship.destroy
    respond_to do |format|
      format.html { redirect_to taxon_name_relationships_url }
      format.json { head :no_content }
    end
  end

  def list
    @taxon_name_relationships = TaxonNameRelationship.with_project_id($project_id).order(:id).page(params[:page])
  end

  # GET /taxon_name_relationships/search
  def search
    if params[:id].blank?
      redirect_to taxon_name_relationship_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to taxon_name_relationship_path(params[:id])
    end
  end

  def autocomplete
    @taxon_name_relationships = taxon_name_relationship.find_for_autocomplete(params.merge(project_id: sessions_current_project_id))
    data = @taxon_name_relationships.collect do |t|
      {id: t.id,
       label: TaxonNameRelationshipsHelper.taxon_name_relationship_tag(t),
       response_values: {
           params[:method] => t.id
       },
       label_html: TaxonNameRelationshipsHelper.taxon_name_relationship_tag(t) #  render_to_string(:partial => 'shared/autocomplete/taxon_name.html', :object => t)
      }
    end

    render :json => data
  end

  # GET /taxon_name_relationships/download
  def download
    send_data TaxonNameRelationship.generate_download(TaxonNameRelationship.where(project_id: $project_id)), type: 'text', filename: "taxon_name_relationships_#{DateTime.now.to_s}.csv"
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_taxon_name_relationship
    @taxon_name_relationship = TaxonNameRelationship.with_project_id($project_id).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def taxon_name_relationship_params
    params.require(:taxon_name_relationship).permit(:subject_taxon_name_id, :object_taxon_name_id, :type, :source_id)
  end
end
