class TaxonNameClassificationsController < ApplicationController
  include DataControllerConfiguration

  before_action :set_taxon_name_classification, only: [:update, :destroy]

  # GET /taxon_name_classifications/new
  def new
    @taxon_name_classification = TaxonNameClassification.new
  end

  # POST /taxon_name_classifications
  # POST /taxon_name_classifications.json
  def create
    @taxon_name_classification = TaxonNameClassification.new(taxon_name_classification_params)

    respond_to do |format|
      if @taxon_name_classification.save
        format.html { redirect_to @taxon_name_classification.becomes(TaxonNameClassification), notice: 'Taxon name classification was successfully created.' }
        format.json { render action: 'show', status: :created, location: @taxon_name_classification.becomes(TaxonNameClassification) }
      else
        format.html { render action: 'new' }
        format.json { render json: @taxon_name_classification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxon_name_classifications/1
  # PATCH/PUT /taxon_name_classifications/1.json
  def update
    respond_to do |format|
      if @taxon_name_classification.update(taxon_name_classification_params)
        format.html { redirect_to @taxon_name_classification.becomes(TaxonNameClassification), notice: 'Taxon name classification was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @taxon_name_classification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /taxon_name_classifications/1
  # DELETE /taxon_name_classifications/1.json
  def destroy
    @taxon_name_classification.destroy
    respond_to do |format|
      format.html { redirect_to taxon_name_classifications_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_taxon_name_classification
      @taxon_name_classification = TaxonNameClassification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def taxon_name_classification_params
      params.require(:taxon_name_classification).permit(:taxon_name_id, :type, :created_by_id, :updated_by_id, :project_id)
    end
end
