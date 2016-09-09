class ConfidencesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_confidence, only: [:show, :edit, :update, :destroy]

  # GET /confidences
  # GET /confidences.json
  def index
    @recent_objects = Confidence.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # # GET /confidences/1
  # # GET /confidences/1.json
  # def show
  # end

  # GET /confidences/new
  def new
    # uggg-ish
    if !ConfidenceLevel.for_confidences.with_project_id(sessions_current_project_id).any? # if there are none
      @return_path = "/confidences/new?confidence[confidence_object_id]=#{params[:confidence][:confidence_object_id]}&confidence[confidence_object_type]=#{params[:confidence][:confidence_object_type]}"
      redirect_to new_controlled_vocabulary_term_path(return_path: @return_path), notice: 'Create a confidence level or two first!' and return
    end
    @confidence = Confidence.new(confidence_params)
  end

  # # GET /confidences/1/edit
  # def edit
  # end

  def list
    @confidences = Confidence.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # POST /confidences
  # POST /confidences.json
  def create
    @confidence = Confidence.new(confidence_params)

    respond_to do |format|
      if @confidence.save
        format.html { redirect_to @confidence.confidence_object.metamorphosize, notice: 'Confidence was successfully created.' }
        format.json { render :show, status: :created, location: @confidence }
      else
        format.html { 
          redirect_to :back, notice: 'Confidence was NOT successfully created.'
        }
        format.json { render json: @confidence.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /confidences/1
  # PATCH/PUT /confidences/1.json
  def update
    respond_to do |format|
      if @confidence.update(confidence_params)
        format.html { redirect_to @confidence, notice: 'Confidence was successfully updated.' }
        format.json { render :show, status: :ok, location: @confidence }
      else
        format.html { render :edit }
        format.json { render json: @confidence.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /confidences/1
  # DELETE /confidences/1.json
  def destroy
    @confidence.destroy
    respond_to do |format|
      format.html { redirect_to confidences_url, notice: 'Confidence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to confidences_path, notice: 'You must select an item from the list with a click or tab press before clicking show'
    else
      redirect_to confidence_path(params[:id])
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_confidence
    @confidence = Confidence.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def confidence_params
    params.require(:confidence).permit(:confidence_level_id, :confidence_object_id, :confidence_object_type)
  end
end
