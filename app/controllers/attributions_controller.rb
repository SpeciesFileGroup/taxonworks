class AttributionsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  
  before_action :set_attribution, only: [:show, :edit, :update, :destroy]
  after_action -> { set_pagination_headers(:attributions) }, only: [:index, :api_index ], if: :json_request?

  # GET /attributions
  # GET /attributions.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Attribution.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @attributions = Queries::Attribution::Filter.new(params).all.where(project_id: sessions_current_project_id).
        page(params[:page]).per(params[:per] || 500)
      }
    end
  end

  # GET /attributions/1
  # GET /attributions/1.json
  def show
  end

  # GET /attributions/new
  # def new
  #   @attribution = Attribution.new
  # end

  # GET /attributions/1/edit
  def edit
  end

  def list
    @attributions = Attribution.with_project_id(sessions_current_project_id).page(params[:page])
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

  # PATCH/PUT /attributions/1
  # PATCH/PUT /attributions/1.json
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

  # DELETE /attributions/1
  # DELETE /attributions/1.json
  def destroy
    @attribution.destroy
    respond_to do |format|
      format.html { redirect_to attributions_url, notice: 'Attribution was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def licenses
    render json: CREATIVE_COMMONS_LICENSES
  end

  def role_types
    render json: ['AttributionCreator', 'AttributionOwner', 'AttributionEditor', 'AttributionCopyrightHolder']
  end

  private

  def set_attribution
    @attribution = Attribution.where(project_id: sessions_current_project_id).find(params[:id])
  end

  def attribution_params
    params.require(:attribution).permit(
      :copyright_year, :license, :attribution_object_type, :attribution_object_id,
      :annotated_global_entity, :_destroy,
      roles_attributes: [
        :id,
        :_destroy,
        :type,
        :person_id,
        :organization_id,
        :position,
        person_attributes: [
          :last_name, :first_name, :suffix, :prefix
        ]])
  end
end
