class BiocurationClassificationsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_biocuration_classification, only: [:update, :destroy]
  after_action -> { set_pagination_headers(:biocuration_classifications) }, only: [:index] # , if: :json_request?

  # GET /biocuration_classifications.json
  def index
    @biocuration_classifications = BiocurationClassification.where(filter_params).page(params[:page])
          .per(params[:per])
 
  end

  # POST /biocuration_classifications
  # POST /biocuration_classifications.json
  def create
    @biocuration_classification = BiocurationClassification.new(biocuration_classification_params)
    respond_to do |format|
      if @biocuration_classification.save
        format.html { redirect_back(fallback_location: (request.referer || root_path), notice: 'Biocuration classification was successfully created.')}
        format.json { render :show, status: :created, location: @biocuration_classification }
      else
        format.html { redirect_back(fallback_location: (request.referer || root_path), notice: 'Biocuration classification was NOT successfully created.')}
        format.json { render json: @biocuration_classification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /biocuration_classifications/1
  # PATCH/PUT /biocuration_classifications/1.json
  def update
    respond_to do |format|
      if @biocuration_classification.update(biocuration_classification_params)
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Biocuration classification was NOT successfully updated.')}
        format.json { head :no_content }
      else
        format.html {redirect_back(fallback_location: (request.referer || root_path), notice: 'Biocuration classification was NOT successfully updated.')}
        format.json { render json: @biocuration_classification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /biocuration_classifications/1
  # DELETE /biocuration_classifications/1.json
  def destroy
    @biocuration_classification.destroy
    respond_to do |format|
      format.html { destroy_redirect @biocuration_classification, notice: 'Biocuration classification was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  def set_biocuration_classification
    @biocuration_classification = BiocurationClassification.with_project_id(sessions_current_project_id).find(params[:id])
  end

  def biocuration_classification_params
    params.require(:biocuration_classification).permit(:biocuration_class_id, :biocuration_classification_object_id, :biocuration_classification_object_type)
  end

  # No corresponding filter.rb
  def filter_params
    return params.permit(:biocuration_class_id, :biocuration_classification_object_id, :biocuration_classification_object_type).merge(project_id: sessions_current_project_id)
  end

end
