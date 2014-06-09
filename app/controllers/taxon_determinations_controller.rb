class TaxonDeterminationsController < ApplicationController
  before_action :require_sign_in_and_project_selection
  before_action :set_taxon_determination, only: [:show, :edit, :update, :destroy]

  # GET /taxon_determinations
  # GET /taxon_determinations.json
  def index
    @taxon_determinations = TaxonDetermination.all
  end

  # GET /taxon_determinations/1
  # GET /taxon_determinations/1.json
  def show
  end

  # GET /taxon_determinations/new
  def new
    @taxon_determination = TaxonDetermination.new
  end

  # GET /taxon_determinations/1/edit
  def edit
  end

  # POST /taxon_determinations
  # POST /taxon_determinations.json
  def create
    @taxon_determination = TaxonDetermination.new(taxon_determination_params)

    respond_to do |format|
      if @taxon_determination.save
        format.html { redirect_to @taxon_determination, notice: 'Taxon determination was successfully created.' }
        format.json { render action: 'show', status: :created, location: @taxon_determination }
      else
        format.html { render action: 'new' }
        format.json { render json: @taxon_determination.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxon_determinations/1
  # PATCH/PUT /taxon_determinations/1.json
  def update
    respond_to do |format|
      if @taxon_determination.update(taxon_determination_params)
        format.html { redirect_to @taxon_determination, notice: 'Taxon determination was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @taxon_determination.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxon_determinations/1
  # DELETE /taxon_determinations/1.json
  def destroy
    @taxon_determination.destroy
    respond_to do |format|
      format.html { redirect_to taxon_determinations_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_taxon_determination
      @taxon_determination = TaxonDetermination.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def taxon_determination_params
      params.require(:taxon_determination).permit(:biological_collection_object_id, :otu_id, :position, :year_made, :month_made, :day_made, :created_by_id, :updated_by_id, :project_id)
    end
end
