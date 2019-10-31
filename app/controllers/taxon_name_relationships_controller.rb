class TaxonNameRelationshipsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_taxon_name_relationship, only: [:show, :edit, :update, :destroy]

  # GET /taxon_name_relationships
  # GET /taxon_name_relationships.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = TaxonNameRelationship.recent_from_project_id(sessions_current_project_id)
                            .order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @taxon_name_relationships = TaxonNameRelationship.where(filter_sql)
                                      .with_project_id(sessions_current_project_id)
      }
    end
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
    @taxon_name_relationship.source = Source.new if !@taxon_name_relationship.source
  end

  # POST /taxon_name_relationships
  # POST /taxon_name_relationships.json
  def create
    @taxon_name_relationship = TaxonNameRelationship.new(taxon_name_relationship_params)

    respond_to do |format|
      if @taxon_name_relationship.save
        format.html { redirect_to url_for(@taxon_name_relationship.metamorphosize),
                                  notice: 'Taxon name relationship was successfully created.' }
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
        @taxon_name_relationship = TaxonNameRelationship.find(@taxon_name_relationship.id) # reset class
        format.html { redirect_to url_for(@taxon_name_relationship.metamorphosize),
                                  notice: 'Taxon name relationship was successfully updated.' }
        format.json { render :show, status: :ok, location: @taxon_name_relationship.metamorphosize }
      else
        format.html { render action: 'edit' }
        format.json { render json: @taxon_name_relationship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxon_name_relationships/1
  # DELETE /taxon_name_relationships/1.json
  def destroy
    @taxon_name_relationship.destroy!
    respond_to do |format|
      format.html { redirect_to taxon_name_relationships_url,
                                notice: 'Taxon name relationship was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def list
    @taxon_name_relationships = TaxonNameRelationship.with_project_id(sessions_current_project_id)
                                  .order(:id).page(params[:page])
  end

  # GET /taxon_name_relationships/search
  def search
    if params[:id].blank?
      redirect_to taxon_name_relationship_path,
                  notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to taxon_name_relationship_path(params[:id])
    end
  end

  # GET /taxon_name_relationships/download
  def download
    send_data Export::Download.generate_csv(TaxonNameRelationship.where(project_id: sessions_current_project_id)),
              type: 'text', filename: "taxon_name_relationships_#{DateTime.now}.csv"
  end

  # GET /taxon_name_relationships/type_relationships
  def type_relationships
    render json: TAXON_NAME_RELATIONSHIPS_TYPE_JSON
  end

  # GET /taxon_name_relationships/taxon_name_relationship_types
  def taxon_name_relationship_types
    render json: TAXON_NAME_RELATIONSHIPS_JSON
  end

  private
  def set_taxon_name_relationship
    @taxon_name_relationship = TaxonNameRelationship.with_project_id(sessions_current_project_id).find(params[:id])
  end

  def taxon_name_relationship_params
    params.require(:taxon_name_relationship).permit(
      :subject_taxon_name_id, :object_taxon_name_id, :type,
      origin_citation_attributes: [:id, :_destroy, :source_id, :pages]
    )
  end

  def filter_sql
    h = params.permit(:taxon_name_id, :as_object, :as_subject, of_type: []).to_h.symbolize_keys
    Queries::TaxonNameRelationshipsFilterQuery.new(h).where_sql
  end

end
