class Tasks::Gis::LocalityController < ApplicationController
  include TaskControllerConfiguration

  def nearby
    if params[:id]
      @collecting_event  = CollectingEvent.where(project_id: sessions_current_project_id).find(params[:id])
      @nearby_distance   = Utilities::Geo.nearby_from_params(params)
      @collecting_events = @collecting_event.collecting_events_within_radius_of(@nearby_distance).where(project_id: sessions_current_project_id).limit(100).order(:verbatim_locality)
    else
      @collecting_event  = CollectingEvent.new()
      @collecting_events = []
      @nearby_distance   = 5000
    end
  end

  def within
    @geographic_item   = GeographicItem.find(params[:id])
    @collecting_events = CollectingEvent.where(project_id: sessions_current_project_id).contained_within(@geographic_item)
  end

  # @return [Scope] Preload an  empty set of collecting events
  def new_list
    @collecting_events = CollectingEvent.where('false')
    @drawing_modes     = 'active: polygon, circle'
  end

  # use the params[:geographic_area_id] to locate the area, use that to find a geographic item
  def list
    case params[:commit]
      when 'Show'
        geographic_area_ids = params[:geographic_area_ids]
        shape_in = params['drawn_area_shape']
        findings = [params['selection_objects']]

        findings.flatten.each { |finding|
          case finding
            when /Collecting/
              @collecting_events = GeographicItem.gather_geographic_area_or_shape_data(geographic_area_ids,
                                                                                       shape_in,
                                                                                       finding,
                                                                                       sessions_current_project_id)
                                       .order(:verbatim_locality)
            else
          end
        }
        @drawing_modes = 'active: polygon, circle'
      else
        # some other case, TBDL
    end
  end

  protected

  # def gather_list_data(geographic_area)
  #   if @geographic_area.has_shape?
  #     @geographic_item = @geographic_area.default_geographic_item
  #   else
  #     @geographic_item = nil
  #   end
  # end

end
