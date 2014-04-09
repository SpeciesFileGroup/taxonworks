class TaxonNameRelationshipsController < ApplicationController
  before_action :set_taxon_name_relationship, only: [:show, :edit, :update, :destroy]

  # GET /taxon_name_relationships
  # GET /taxon_name_relationships.json
  def index
    @taxon_name_relationships = TaxonNameRelationship.all
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
        format.html { redirect_to @taxon_name_relationship.becomes(TaxonNameRelationship), notice: 'Taxon name relationship was successfully created.' }
        format.json { render action: 'show', status: :created, location: @taxon_name_relationship.becomes(TaxonNameRelationship) }
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
        format.html { redirect_to @taxon_name_relationship.becomes(TaxonNameRelationship), notice: 'Taxon name relationship was successfully updated.' }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_taxon_name_relationship
      @taxon_name_relationship = TaxonNameRelationship.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def taxon_name_relationship_params
      params.require(:taxon_name_relationship).permit(:subject_taxon_name_id, :object_taxon_name_id, :type, :created_by_id, :updated_by_id, :project_id, :source_id)
    end
end
