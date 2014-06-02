class TaxonNamesController < ApplicationController
  before_action :set_taxon_name, only: [:show, :edit, :update, :destroy]

  # GET /taxon_names
  # GET /taxon_names.json
  def index
    @taxon_names = TaxonName.limit(100)
  end

  # GET /taxon_names/1
  # GET /taxon_names/1.json
  def show
  end

  # GET /taxon_names/new
  def new
    @taxon_names = TaxonName.all
    @taxon_name = TaxonName.new
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
        format.html { redirect_to @taxon_name, notice: 'Taxon name was successfully created.' }
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
        format.html { redirect_to @taxon_name.becomes(TaxonName), notice: 'Taxon name was successfully updated.' }
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

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_taxon_name
    @taxon_name = TaxonName.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def taxon_name_params
    params.require(:taxon_name).permit(:name, :parent_id, :cached_name, :cached_author_year, :cached_higher_classification, :lft, :rgt, :source_id, :year_of_publication, :verbatim_author, :rank_class, :type, :created_by_id, :updated_by_id, :project_id, :cached_original_combination, :cached_secondary_homonym, :cached_primary_homonym, :cached_secondary_homonym_alt, :cached_primary_homonym_alt)
  end

  def demo
    @taxon_name = TaxonName.first
  end

  def marilyn
    @users=User.all
  end

end
