class Tasks::Gis::MatchGeoreferenceController < ApplicationController

  def index
    # some things on to which to hang one's hat.
    @collecting_event = CollectingEvent.new
    @georeference = Georeference.new
    @collecting_events = []
    @georeferences = []
  end

  def filtered_collecting_events
    message = ''
    @collecting_events = CollectingEvent.filter(params) #

    if @collecting_events.length == 0
      message = 'no collecting events selected'
    end
    render_ce_select_json(message)
  end

  def recent_collecting_events
    message = ''
    how_many = params['how_many']
    @collecting_events = CollectingEvent.where(project_id: $project_id).order(updated_at: :desc).limit(how_many.to_i)
    if @collecting_events.length == 0
      message = 'no recent objects selected'
    end
    render_ce_select_json(message)
  end

  def tagged_collecting_events
    message = ''
    if params[:keyword_id].blank?
      # Bad search request; return not a list but back to the form
      @collecting_events = CollectingEvent.where('false')
    else
      keyword = Keyword.find(params[:keyword_id])
      @collecting_events = CollectingEvent.where(project_id: $project_id).order(updated_at: :desc).tagged_with_keyword(keyword)
    end
    if @collecting_events.length == 0
      message = 'no tagged objects selected' #and return
    end
    render_ce_select_json(message)
  end

  def drawn_collecting_events
    message = ''
    value = params['ce_geographic_item_attributes_shape']
    if value.blank?
      @collecting_events = CollectingEvent.where('false')
    else
      feature = RGeo::GeoJSON.decode(value, :json_parser => :json)
      # isolate the WKT
      geometry = feature.geometry
      this_type = geometry.geometry_type.to_s.downcase
      geometry = geometry.as_text
      radius = feature['radius']
      case this_type
        when 'point'
          @collecting_events = GeographicItem.with_collecting_event_through_georeferences.within_radius_of_wkt('any', geometry, radius).map(&:georeferences).uniq.flatten.map(&:collecting_event)
        when 'polygon'
          @collecting_events = GeographicItem.with_collecting_event_through_georeferences.are_contained_in_wkt('any', geometry).map(&:georeferences).uniq.flatten.map(&:collecting_event)
        else
      end
    end
    if @collecting_events.length == 0
      message = 'no georeferences found'
    end
    render_ce_select_json(message)
  end

  def filtered_georeferences
    message = ''
    @georeferences = Georeference.filter(params)
    if @georeferences.length == 0
      message = 'no georeferences found'
    end
    render_gr_select_json(message)
  end

  def recent_georeferences
    message = ''
    how_many = params['how_many']
    @georeferences = Georeference.where(project_id: $project_id).order(updated_at: :desc).limit(how_many.to_i)
    if @georeferences.length == 0
      message = 'no recent georeferences selected'
    end
    render_gr_select_json(message)
  end

  def tagged_georeferences
    message = ''

    # todo: this needs to be rationalized, but works, after a fashion.
    if params[:keyword_id].blank?
      # render json: {html: 'Empty set'} #and return
      @georeferences = Georeference.where('false')
    else
      keyword = Keyword.find(params[:keyword_id])
      @georeferences = Georeference.where(project_id: $project_id).order(updated_at: :desc).tagged_with_keyword(keyword)
    end
    if @georeferences.length == 0
      message = 'no tagged objects selected'
    end
    render_gr_select_json(message)
  end

  def drawn_georeferences
    message = ''
    value = params['gr_geographic_item_attributes_shape']
    if value.blank?
      @georeferences = Georeference.where('false')
    else
      feature = RGeo::GeoJSON.decode(value, :json_parser => :json)
      # isolate the WKT
      geometry = feature.geometry
      this_type = geometry.geometry_type.to_s.downcase
      geometry = geometry.as_text
      radius = feature['radius']
      case this_type
        when 'point'
          @georeferences = GeographicItem.with_collecting_event_through_georeferences.within_radius_of_wkt('any', geometry, radius).map(&:georeferences).uniq.flatten
        when 'polygon'
          @georeferences = GeographicItem.with_collecting_event_through_georeferences.are_contained_in_wkt('any', geometry).map(&:georeferences).uniq.flatten
        else
      end
    end
    if @georeferences.length == 0
      message = 'no objects contained in drawn shape'
    end
    render_gr_select_json(message)
  end

  def batch_create_match_georeferences
    message = ''
    respond_to do |format|
      format.json {
        # we want to repackage the checkmarks we get from the client side into an array of ids with which
        # to feed Georeference.
        keys = params.keys
        checked_ids = []
        arguments = {}
        keys.each { |key|
          if /check\d+/ =~ key
            checked_ids.push(params[key].to_i)
          end
        }
        arguments.merge!(georeference_id: params['georeference_id'])
        arguments.merge!(checked_ids: checked_ids)

        results = Georeference.batch_create_from_georeference_matcher(arguments)

        if results.length == 0
          message = 'No collecting events were selected.'
        end

        html = render_to_string(partial: 'georeference_success', formats: 'html',
                                locals: {georeferences_results: results}
        )

        render json: {message: message,
                      html: html
               }
        # render json: {message: '',
        #               html:    results}
      }
    end
  end

  # @param [String] message to be conveyed to client side
  # @return [JSON] with html for collecting events display (table of selectable collecting events)
  def render_ce_select_json(message)
    # retval = render_to_html
    render json: {message: message, html: ce_render_to_html}
  end

  # @param [String] message to be conveyed to client side
  # @return [JSON] with html for georeferences display (feature collection)
  def render_gr_select_json(message)
    render json: {message: message, html: gr_render_to_html}
  end

  # @return [String] of html for partial
  def ce_render_to_html
    render_to_string(partial: 'tasks/gis/match_georeference/collecting_event_selections',
                     locals: {collecting_events: @collecting_events})
  end

  # @return [String] of html for partial
  def gr_render_to_html
    render_to_string(partial: 'tasks/gis/match_georeference/georeferences_selections_form',
                     locals: {georeferences: @georeferences})
  end
end
