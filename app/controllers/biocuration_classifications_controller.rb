class BiocurationClassificationsController < ApplicationController
  include DataControllerConfiguration

  before_action :set_biocuration_classification, only: [:show, :edit, :update, :destroy]

  # GET /biocuration_classifications
  # GET /biocuration_classifications.json
  def index
    @biocuration_classifications = BiocurationClassification.all
  end

  # GET /biocuration_classifications/1
  # GET /biocuration_classifications/1.json
  def show
  end

  # GET /biocuration_classifications/new
  def new
    @biocuration_classification = BiocurationClassification.new
  end

  # GET /biocuration_classifications/1/edit
  def edit
  end

  # POST /biocuration_classifications
  # POST /biocuration_classifications.json
  def create
    @biocuration_classification = BiocurationClassification.new(biocuration_classification_params)

    respond_to do |format|
      if @biocuration_classification.save
        format.html { redirect_to @biocuration_classification, notice: 'Biocuration classification was successfully created.' }
        format.json { render action: 'show', status: :created, location: @biocuration_classification }
      else
        format.html { render action: 'new' }
        format.json { render json: @biocuration_classification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /biocuration_classifications/1
  # PATCH/PUT /biocuration_classifications/1.json
  def update
    respond_to do |format|
      if @biocuration_classification.update(biocuration_classification_params)
        format.html { redirect_to @biocuration_classification, notice: 'Biocuration classification was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @biocuration_classification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /biocuration_classifications/1
  # DELETE /biocuration_classifications/1.json
  def destroy
    @biocuration_classification.destroy
    respond_to do |format|
      format.html { redirect_to biocuration_classifications_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_biocuration_classification
      @biocuration_classification = BiocurationClassification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def biocuration_classification_params
      params.require(:biocuration_classification).permit(:biocuration_class_id, :biological_collection_object_id, :position, :created_by_id, :updated_by_id, :project_id)
    end
end
