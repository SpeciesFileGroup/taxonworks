class Tasks::Gis::MatchGeoreferenceController < ApplicationController
  include TaskControllerConfiguration

  def index
    @collecting_event = CollectingEvent.new
    @georeference = Georeference.new
    @collecting_events = []
    @georeferences = []
  end

  def filtered_collecting_events
    message = ''
    @collecting_events = CollectingEvent.with_project_id(sessions_current_project_id).filter(params)

    if @collecting_events.blank?
      message = 'no collecting events selected'
    end
    render_ce_select_json(message)
  end

  def recent_collecting_events
    message = ''
    how_many = params['how_many']
    @collecting_events = CollectingEvent.with_project_id(sessions_current_project_id)
                             .order(updated_at: :desc)
                             .limit(how_many.to_i)

    if @collecting_events.blank?
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
      @collecting_events = CollectingEvent.with_project_id(sessions_current_project_id)
                               .order(updated_at: :desc)
                               .tagged_with_keyword(keyword)
    end

    if @collecting_events.blank?
      message = 'no tagged objects selected'
    end
    render_ce_select_json(message)
  end

  def drawn_collecting_events

    message = ''
    value = params['ce_geographic_item_attributes_shape']
    if value.blank?
      @collecting_events = CollectingEvent.where('false')
    else
      feature = RGeo::GeoJSON.decode(value, json_parser: :json)
      # isolate the WKT
      geometry = feature.geometry
      this_type = geometry.geometry_type.to_s.downcase
      geometry = geometry.as_text
      radius = feature['radius']
      case this_type
        when 'point'
          @collecting_events = CollectingEvent.with_project_id(sessions_current_project_id)
                                   .joins(:geographic_items)
                                   .where(GeographicItem.within_radius_of_wkt_sql(geometry, radius))
        when 'polygon'
          @collecting_events = CollectingEvent.with_project_id(sessions_current_project_id)
                                   .joins(:geographic_items)
                                   .where(GeographicItem.contained_by_wkt_sql(geometry))
        else
      end
    end

    if @collecting_events.blank?
      message = 'no georeferences found'
    end
    render_ce_select_json(message)
  end

  def filtered_georeferences
    message = ''
    @georeferences = Georeference.with_project_id(sessions_current_project_id).filter(params)
    if @georeferences.blank?
      message = 'no georeferences found'
    end
    render_gr_select_json(message)
  end

  def recent_georeferences
    message = ''
    how_many = params['how_many']
    @georeferences = Georeference.with_project_id(sessions_current_project_id)
                         .order(updated_at: :desc)
                         .limit(how_many.to_i)
    if @georeferences.blank?
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
      @georeferences = Georeference.with_project_id(sessions_current_project_id)
                           .order(updated_at: :desc)
                           .tagged_with_keyword(keyword)
    end
    if @georeferences.blank?
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
      feature = RGeo::GeoJSON.decode(value, json_parser: :json)
      # isolate the WKT
      geometry = feature.geometry
      this_type = geometry.geometry_type.to_s.downcase
      geometry = geometry.as_text
      radius = feature['radius']
      case this_type
        when 'point'
          @georeferences = Georeference.with_project_id(sessions_current_project_id)
                               .joins(:geographic_item)
                               .where(GeographicItem.within_radius_of_wkt_sql(geometry, radius))
        when 'polygon'
          @georeferences = Georeference.with_project_id(sessions_current_project_id)
                               .joins(:geographic_item)
                               .where(GeographicItem.contained_by_wkt_sql(geometry))
        else
      end
    if @georeferences.blank?
      message = 'no objects contained in drawn shape'
    end
    render_gr_select_json(message)
    end
  end

  #
  # def anti_meridian_check(last_x, this_x) # returns true if anti-meridian crossed
  #   if last_x
  #     if last_x <= 0
  #       if (((this_x >= 0 || this_x < -180))) # sign change from west to east
  #         xm = (0.5 * (this_x - last_x)).abs # find intersection
  #         if (xm > 90)
  #           return true
  #         end
  #       end
  #     end
  #     if last_x >= 0
  #       if (((this_x <= 0) || this_x > 180))
  #         xm = (0.5 * (last_x - this_x)).abs
  #         if (xm > 90)
  #           return true
  #         end
  #       end
  #     end
  #   end
  #   false
  # end
  #
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

        arguments[:georeference_id] = params['georeference_id']
        arguments[:checked_ids] = checked_ids

        results = Georeference.with_project_id(sessions_current_project_id)
                      .batch_create_from_georeference_matcher(arguments)

        if results.blank?
          message = 'No collecting events were selected.'
        end

        html = render_to_string(partial: 'georeference_success', formats: 'html',
                                locals: {georeferences_results: results}
        )

        render json: {message: message,
                      html: html
        }
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
