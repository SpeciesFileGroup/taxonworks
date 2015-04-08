class GeoreferencesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_georeference, only: [:show, :edit, :update, :destroy]
  # before_action :disable_turbolinks, only: [:show, :list, :index]

  # GET /georeferences
  # GET /georeferences.json
  def index
    @recent_objects = Georeference.recent_from_project_id($project_id).order(updated_at: :desc).limit(10)
    render '/shared/data/all/index'
  end

  def list
    @georeferences = Georeference.with_project_id($project_id).order(:id).page(params[:page]) #.per(10) #.per(3)
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
    target = @georeference.collecting_event if target.nil?

    respond_to do |format|
      format.html { redirect_to target, notice: 'All collecting events have georeferences.' }
      format.json { render action: 'show', status: :created, location: target }
    end
  end

  # POST /georeferences
  # POST /georeferences.json
  def create
    @georeference = Georeference.new(georeference_params)
    if params['skip_next'].nil?
      respond_to do |format|
        if @georeference.save
       
        # target = @georeference.collecting_event

        # unless params['commit_next'].nil?
        #   new_target = @georeference.collecting_event.next_without_georeference
        #   target     = new_target unless new_target.nil?
        # end
       
          format.html {   
            if false

            else    
              redirect_to collecting_event_path(@georeference.collecting_event), notice: 'Georeference was successfully created.'
            end
          }

          format.json { render action: 'show', status: :created }
        
        else
          
          format.html { 
            if @georeference.method_name 
              render "/georeferences/#{@georeference.method_name}/new"
            else
              if @georeference.collecting_event
                 redirect_to collecting_event_path(@georeference.collecting_event), notice: 'Georeference not created, check verbatim values of collecting event'
              else
                 redirect_to georeferences_path, notice: 'Georeference not created.  Contact administrator with details if you recieved this message.'
              end 
            end
          }

          format.json { render json: @georeference.errors, status: :unprocessable_entity }
        end
      end
    else
      skip
    end
  end

  def batch_create

  end

  # PATCH/PUT /georeferences/1
  # PATCH/PUT /georeferences/1.json
  #  def update
  #    respond_to do |format|
  #      if @georeference.update(georeference_params)
  #  
  #        format.html { redirect_to @georeference.metamorphosize, notice: 'Georeference was successfully updated.' }
  #        format.json { head :no_content }
  #      else
  #        format.html { render action: :edit} #  "/georeferences/#{@georeference.method_name}/edit"}
  #        format.json { render json: @georeference.errors, status: :unprocessable_entity }
  #      end
  #    end
  #  end

  # DELETE /georeferences/1
  # DELETE /georeferences/1.json
  def destroy
    @georeference.destroy
    respond_to do |format|
      format.html { redirect_to georeferences_url }
      format.json { head :no_content }
    end
  end

  # GET /georeferences/download
  def download
    send_data Georeference.generate_download(Georeference.where(project_id: $project_id)), type: 'text', filename: "georeferences_#{DateTime.now.to_s}.csv"
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_georeference
    @georeference = Georeference.with_project_id($project_id).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def georeference_params
    params.require(:georeference).permit(:iframe_response,
                                         :submit,
                                         :geographic_item_id,
                                         :collecting_event_id,
                                         :error_radius,
                                         :error_depth,
                                         :error_geographic_item_id,
                                         :type,
                                         :source_id,
                                         :position,
                                         :is_public,
                                         :api_request,
                                         :is_undefined_z,
                                         :is_median_z,
                                         :geographic_item_attributes => [:shape])
  end
end
