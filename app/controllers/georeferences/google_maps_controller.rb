class Georeferences::GoogleMapsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  # GET /georeferences/google_maps/new
  def new
    @georeference = Georeference::GoogleMap.new(georeference_params)
  end

  # POST /georeferences/google_maps
  # POST /georeferences/google_maps.json
  def create
    @georeference = Georeference::GoogleMap.new(georeference_params)
    respond_to do |format|
      if @georeference.save
        format.html {  
          flash[:notice] = 'Georeference was successfully created.'
          if params[:commit_and_next] 
            redirect_to new_georeferences_google_map_path(georeference: {collecting_event_id: @georeference.collecting_event.next_without_georeference } )   
          else    
            redirect_to collecting_event_path(@georeference.collecting_event)
          end
        }
        format.json { render action: 'show', status: :created }
      else
        format.html { render :new }
        format.json { render json: @georeference.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def georeference_params
    p = params.require(:georeference).permit(:collecting_event_id,
                                             :type,
                                             :is_public,
                                             :geo_type,
                                             :geographic_item_attributes => [:shape])
    p.merge!(collecting_event: CollectingEvent.new) if params[:georeference][:collecting_event_id].blank?
    p.merge!(geographic_item: GeographicItem.new) if params[:georeference][:geographic_item_id].blank?
    p    
  end

 # Over-ride the default model setting for this subclass
  def set_data_model
    @data_model = 'Georeference::GoogleMap'
  end
end
