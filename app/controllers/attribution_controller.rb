class AttributionController < ApplicationController
  before_action :set_attribution, only: [:show, :edit, :update, :destroy]

  # GET /attribution
  # GET /attribution.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Attribution.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
   #   format.json {
   #     @otus = Attribution.all.page(params[:page]).per(500)
   #   }
    end
  end

  # GET /attribution/1
  # GET /attribution/1.json
  def show
  end

  # GET /attribution/new
  def new
    @attribution = Attribution.new
  end

  # GET /attribution/1/edit
  def edit
  end

  # POST /attribution
  # POST /attribution.json
  def create
    @attribution = Attribution.new(attribution_params)

    respond_to do |format|
      if @attribution.save
        format.html { redirect_to @attribution, notice: 'Attribution was successfully created.' }
        format.json { render :show, status: :created, location: @attribution }
      else
        format.html { render :new }
        format.json { render json: @attribution.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /attribution/1
  # PATCH/PUT /attribution/1.json
  def update
    respond_to do |format|
      if @attribution.update(attribution_params)
        format.html { redirect_to @attribution, notice: 'Attribution was successfully updated.' }
        format.json { render :show, status: :ok, location: @attribution }
      else
        format.html { render :edit }
        format.json { render json: @attribution.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attribution/1
  # DELETE /attribution/1.json
  def destroy
    @attribution.destroy
    respond_to do |format|
      format.html { redirect_to attribution_index_url, notice: 'Attribution was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attribution
      @attribution = Attribution.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def attribution_params
      params.require(:attribution).permit(:copyright_year, :license)
    end
end
