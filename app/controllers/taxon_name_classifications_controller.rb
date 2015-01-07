class TaxonNameClassificationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_taxon_name_classification, only: [ :update, :destroy]

  # POST /taxon_name_classifications
  # POST /taxon_name_classifications.json
  def create
    @taxon_name_classification = TaxonNameClassification.new(taxon_name_classification_params)

    respond_to do |format|
      if @taxon_name_classification.save
        format.html { redirect_to :back, notice: 'Taxon name classification was successfully created.' }
        format.json { render json: @taxon_name_classification, status: :created, location: @taxon_name_classification.metamorphosize }
      else
        format.html { redirect_to :back, notice: 'Taxon name classification was NOT successfully created.' }
        format.json { render json: @taxon_name_classification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /taxon_name_classifications/1
  # PATCH/PUT /taxon_name_classifications/1.json
  def update
    respond_to do |format|
      if @taxon_name_classification.update(taxon_name_classification_params)
        format.html { redirect_to :back, notice: 'Taxon name classification was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { redirect_to :back, notice: 'Taxon name classification was NOT successfully updated.' }
        format.json { render json: @taxon_name_classification.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    @taxon_name_classification = TaxonNameClassification.new(taxon_name: TaxonName.find(params.permit(:taxon_name_id)['taxon_name_id']))
  end

  # DELETE /taxon_name_classifications/1
  # DELETE /taxon_name_classifications/1.json
  def destroy
    @taxon_name_classification.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Taxon name classification was successfully destroyed.' }
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
