class ExtractsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_extract, only: [:show, :edit, :update, :destroy]

  # GET /extracts
  # GET /extracts.json
  def index
    @recent_objects = Extract.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  # GET /extracts/1
  # GET /extracts/1.json
  def show
  end

  # GET /extracts/new
  def new
    @extract = Extract.new
  end

  # GET /extracts/1/edit
  def edit
  end

  def list
    @extracts = Extract.with_project_id(sessions_current_project_id).page(params[:page])
  end

  # POST /extracts
  # POST /extracts.json
  def create
    @extract = Extract.new(extract_params)

    respond_to do |format|
      if @extract.save
        format.html { redirect_to @extract, notice: 'Extract was successfully created.' }
        format.json { render :show, status: :created, location: @extract }
      else
        format.html { render :new }
        format.json { render json: @extract.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /extracts/1
  # PATCH/PUT /extracts/1.json
  def update
    respond_to do |format|
      if @extract.update(extract_params)
        format.html { redirect_to @extract, notice: 'Extract was successfully updated.' }
        format.json { render :show, status: :ok, location: @extract }
      else
        format.html { render :edit }
        format.json { render json: @extract.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /extracts/1
  # DELETE /extracts/1.json
  def destroy
    @extract.destroy
    respond_to do |format|
      format.html { redirect_to extracts_url, notice: 'Extract was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def search
    if params[:id].blank?
      redirect_to extracts_path, notice: 'You must select an item from the list with a click or tab press before clicking show.'
    else
      redirect_to extract_path(params[:id])
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_extract
      @extract = Extract.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extract_params
      params.require(:extract).permit(:quantity_value, :quantity_unit, :concentration_value, :concentration_unit, :verbatim_anatomical_origin, :year_made, :month_made, :day_made)
    end
end
