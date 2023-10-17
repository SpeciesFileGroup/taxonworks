class Georeferences::GeoLocatesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  # POST /georeferences/geo_locates
  # POST /georeferences/geo_locates.json
  def create
    @georeference = Georeference::GeoLocate.new(georeference_params)
    respond_to do |format|
      if @georeference.save
        format.html {
          if false

          else
            redirect_to collecting_event_path(@georeference.collecting_event), notice: 'Georeference was successfully created.'
          end
        }

        format.json { render action: 'show', status: :created }
      else
        format.html {
          #         if @georeference.method_name
          #           render "/georeferences/#{@georeference.method_name}/new"
          #         else
          render :new, notice: 'Georeference not created, check verbatim values of collecting event'
          #           if @georeference.collecting_event
          #             redirect_to collecting_event_path(@georeference.collecting_event),
          #           else
          #             redirect_to georeferences_path, notice: 'Georeference not created.  Contact administrator with details if you received dthis message.'
          #           end
          #         end
        }

        format.json { render json: @georeference.errors, status: :unprocessable_entity }
      end
    end
  end


  # GET /georeferences/geo_locate/new
  def new
    #   @collecting_event = CollectingEvent.find(params.permit(:collecting_event_id)[:collecting_event_id]) if params.permit(:collecting_event_id)[:collecting_event_id]
    attributes           = {}
    attributes           = georeference_params if params[:georeference]
    @georeference        = Georeference::GeoLocate.new(attributes)
    @georeference.source ||= Source.new()

  end

  protected

  def georeference_params
    params.require(:georeference).permit(:iframe_response,
                                         :submit,
                                         :collecting_event_id,
                                         :type,
                                         :is_public,
                                         :api_request,
                                         origin_citation_attributes: [:id, :_destroy, :source_id, :pages]
    )
  end

  # Over-ride the default model setting for this subclass
  def set_data_model
    @data_model = Georeference::GeoLocate
  end


end
