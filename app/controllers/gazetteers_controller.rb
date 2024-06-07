class GazetteersController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration
  before_action :set_gazetteer, only: %i[ show edit update destroy ]

  # GET /gazetteers
  # GET /gazetteers.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Gazetteer.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json do
        @geographic_areas = ::Queries::GeographicArea::Filter.new(params).all
          .includes(:geographic_items)
          .page(params[:page])
          .per(params[:per])
          # .order('geographic_items.cached_total_area, geographic_area.name')
      end
    end
  end

  # GET /gazetteers/1 or /gazetteers/1.json
  def show
  end

  # GET /gazetteers/new
  def new
    @gazetteer = Gazetteer.new
  end

  # GET /gazetteers/1/edit
  def edit
  end

  # POST /gazetteers or /gazetteers.json
  def create
    @gazetteer = Gazetteer.new(gazetteer_params)

    respond_to do |format|
      if @gazetteer.save
        format.html { redirect_to gazetteer_url(@gazetteer), notice: "Gazetteer was successfully created." }
        format.json { render :show, status: :created, location: @gazetteer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @gazetteer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /gazetteers/1 or /gazetteers/1.json
  def update
    respond_to do |format|
      if @gazetteer.update(gazetteer_params)
        format.html { redirect_to gazetteer_url(@gazetteer), notice: "Gazetteer was successfully updated." }
        format.json { render :show, status: :ok, location: @gazetteer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @gazetteer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gazetteers/1 or /gazetteers/1.json
  def destroy
    @gazetteer.destroy!

    respond_to do |format|
      format.html { redirect_to gazetteers_url, notice: "Gazetteer was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_gazetteer
    @gazetteer = Gazetteer.find(params[:id])
  end

  def gazetteer_params
    params.require(:gazetteer).permit(:name, :parent_id, :iso_3166_a2, :iso_3166_a3)
  end
end
