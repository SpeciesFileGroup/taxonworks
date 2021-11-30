class GeoreferencesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_georeference, only: [:show, :edit, :update, :destroy]

  # GET /georeferences
  # GET /georeferences.json
  def index
    respond_to do |format|
      format.html do
        @recent_objects = Georeference.recent_from_project_id(sessions_current_project_id).order(updated_at: :desc).limit(10)
        render '/shared/data/all/index'
      end
      format.json {
        @georeferences = Queries::Georeference::Filter.new(filter_params).all.where(project_id: sessions_current_project_id).page(params[:page]).per(50)
      }
    end
  end

  def list
    @georeferences = Georeference.with_project_id(sessions_current_project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
  end

  # GET /georeferences/1
  # GET /georeferences/1.json
  def show
  end

  # GET /georeferences/1
  # GET /georeferences/1.json
  def new
    redirect_to new_georeferences_geo_locate_path
  end

  # GET /georeferences/1/edit
  def edit
    # presents a "Can't edit message at present"
  end

  # GET /georeferences/skip
  def skip
    target = @georeference.collecting_event.next_without_georeference
    target = @georeference.collecting_event if target.nil?  # TODO: check on subsequent use of 'target'

    respond_to do |format|
      format.html { redirect_to target, notice: 'All collecting events have georeferences.' }
      format.json { render action: 'show', status: :created, location: target }
    end
  end

  # POST /georeferences
  # POST /georeferences.json
  #  def create
  #    @georeference = Georeference.new(georeference_params)
  #    respond_to do |format|
  #      if @georeference.save
  #        format.html {
  #          redirect_to collecting_event_path(@georeference.collecting_event), notice: 'Georeference was successfully created.'
  #        }
  #        format.json { render action: 'show', status: :created }
  #      else
  #  
  #        format.html {
  #          if @georeference.method_name
  #            render "/georeferences/#{@georeference.method_name}/new"
  #          else
  #            if @georeference.collecting_event
  #              redirect_to collecting_event_path(@georeference.collecting_event), notice: 'Georeference not created, check verbatim values of collecting event'
  #            else
  #              redirect_to georeferences_path, notice: 'Georeference not created.  Contact administrator with details if you recieved this message.'
  #            end
  #          end
  #        }
  #  
  #        format.json { render json: @georeference.errors, status: :unprocessable_entity }
  #      end
  #    end
  #  else
  #    skip
  #  end

  # TODO: Fix other georefernce Tasks/interfaces to use JSON, not this ^

  # POST /georeferences
  # POST /georeferences.json
  def create
    @georeference = Georeference.new(georeference_params)
    respond_to do |format|
      if @georeference.save
        format.html {
          redirect_to collecting_event_path(@georeference.collecting_event), notice: 'Georeference was successfully created.'
        }
        format.json { render :show, status: :created, location: @georeference.metamorphosize }
      else
        format.html { render action: :new }
        format.json { render json: @georeference.errors, status: :unprocessable_entity }
      end
    end
  end


  def batch_create
  end

  # PATCH/PUT /georeferences/1
  # PATCH/PUT /georeferences/1.json
  def update
    respond_to do |format|
      if @georeference.update(georeference_params)
        format.html { redirect_to @georeference.metamorphosize, notice: 'Georeference was successfully updated.' }
        format.json { render :show, status: :ok, location: @georeference.metamorphosize }
      else
        format.html { render action: :edit} #  "/georeferences/#{@georeference.method_name}/edit"}
        format.json { render json: @georeference.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /georeferences/1
  # DELETE /georeferences/1.json
  def destroy
    @georeference.destroy!
    respond_to do |format|
      format.html { redirect_to georeferences_url }
      format.json { head :no_content }
    end
  end

  # GET /georeferences/download
  def download
    send_data(
      Export::Download.generate_csv(Georeference.where(project_id: sessions_current_project_id)),
      type: 'text',
      filename: "georeferences_#{DateTime.now}.csv")
  end

  private

  def filter_params
    params.permit(
      :collecting_event_id,
      collecting_event_ids: [],
    )
  end

  def set_georeference
    @georeference = Georeference.with_project_id(sessions_current_project_id).find(params[:id])
    @recent_object = @georeference
  end

  def georeference_params
    params.require(:georeference).permit(
      :iframe_response,
      :submit,
      :geographic_item_id,
      :collecting_event_id,
      :error_radius,
      :error_depth,
      :error_geographic_item_id,
      :type,
      :position,
      :is_public,
      :api_request,
      :is_undefined_z,
      :is_median_z,
      :year_georeferenced,
      :day_georeferenced,
      :month_georeferenced,
      :wkt,
      geographic_item_attributes: [:shape],
      origin_citation_attributes: [:id, :_destroy, :source_id, :pages]
    )
  end
end
