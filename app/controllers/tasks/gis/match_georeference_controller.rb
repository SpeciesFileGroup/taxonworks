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
    @collecting_events = CollectingEvent.filter(params)

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
      feature = RGeo::GeoJSON.decode(value, :json_parser => :json)
      # isolate the WKT
      geometry = feature.geometry
      this_type = geometry.geometry_type.to_s.downcase
      geometry = geometry.as_text
      radius = feature['radius']
      case this_type
        when 'point'
          @collecting_events = CollectingEvent.joins(:geographic_items).where(GeographicItem.within_radius_of_wkt_sql(geometry, radius))
        when 'polygon'
          @collecting_events = CollectingEvent.joins(:geographic_items).where(GeographicItem.contained_by_wkt_sql(geometry))
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
          @georeferences = Georeference.joins(:geographic_item).where(GeographicItem.within_radius_of_wkt_sql(geometry, radius))
        when 'polygon'
          # ob = JSON.parse(value) # check for anti-meridian crossing polygon
          # coords = ob['geometry']['coordinates'][0] # get the coordinates
          #
          # last_x = nil; this_x = nil; anti_chrossed = false # initialize for anti-meridian detection
          # last_y = nil; this_y = nil; bias_x = 360 #          # this section can be generalized for > 2 crossings
          # point_1 = nil; point_1_x = nil; point_1_y = nil;
          # point_2 = nil; point_2_x = nil; point_2_y = nil;
          # coords_1 = []; coords_2 = [];
          # coords.each_with_index { |point, index|
          #   this_x = coords[index][0] #                   # get x value
          #   this_y = coords[index][1] #                   # get y value
          #   if (anti_meridian_check(last_x, this_x))
          #     anti_chrossed = true #                      # set flag if detector triggers
          #     bias_x = -360 #                             # IF we are crossing from east to west
          #     if (last_x < 0) #                           # we are crossing from west to east
          #       bias_x = 360 #                            # reverse bias
          #     end
          #     delta_x = (this_x - last_x) - bias_x #      # assume west to east crossing for now
          #     delta_y = this_y - last_y #                 # don't care if we cross the equator
          #     if (point_1 == nil) #                       # if this is the first crossing
          #       point_1 = index #                         # this is the point after which we insert
          #       point_1_x = -180 #                        # terminus for western hemisphere
          #       if last_x > 0 #                           # wrong assumption, reverse
          #         point_1_x = -point_1_x
          #       end
          #       d_x = point_1_x - last_x #                # distance from last point to terminus
          #       point_1_y = last_y + d_x * delta_y / delta_x
          #     else
          #       point_2 = index
          #       point_2_x = -point_1_x #                 # this is only true for the degenerate case of only 2 crossings
          #       d_x = point_2_x - last_x
          #       point_2_y = last_y + d_x * delta_y / delta_x
          #     end
          #   end
          #   last_x = this_x #                           # move to next line segment
          #   last_y = this_y #                           # until polygon start point
          # }
          # if (anti_chrossed)
          #   index_1 = 0; index_2 = 0 #                  # indices into the constructed semi-polygons
          #   coords.each_with_index { |point, index|
          #     if index < point_1 #                      # first phase, initial points before transit
          #       coords_1[index] = point #               # just transcribe the points to polygon 1
          #     end
          #     if index == point_1 #                     # first transit
          #       coords_1[point_1] = [point_1_x, point_1_y] # truncate first polygon at anti-meridian
          #       coords_1[point_1 + 1] = [point_1_x, point_2_y] # continue truncation with second intersection point
          #       index_1 = index + 2 #                   # set up next insertion point for first polygon
          #
          #       coords_2[0] = [point_2_x, point_2_y] # begin polygon 2 with the mirror line in the opposite direction
          #       coords_2[1] = [point_2_x, point_1_y] # then first intersection where x is fixed at anti-meridian
          #       coords_2[2] = point #                    # continue second polygon with first point past transition
          #       index_2 = 3 #                           # set up next insertion point
          #     end
          #     if index > point_1 && index < point_2 #   # continue second polygon from its stub
          #       coords_2[index_2] = point #             # transcribe the next point(s)
          #       index_2 = index_2 + 1
          #     end
          #     if index == point_2 #                     # second transit
          #       coords_2[index_2] = [point_2_x, point_2_y] # # end the second polygon with the mirror line origin point
          #       coords_1[index_1] = point #             # copy the current original point to the first polygon
          #       index_1 = index_1 + 1 #                 # update its pointer, finished with polygon 2
          #     end
          #     if index > point_2 #                      # final phase, finish up polygon 1
          #       coords_1[index_1] = point #             # transcribe any remaining points
          #       index_1 = index_1 + 1 #                 # update its pointer until we reach the initial point
          #     end
          #   }
          #
          #   ob["geometry"]["type"] = 'MultiPolygon'
          #   ob["geometry"]["coordinates"] = []  #                     # replace the original coordinates
          #   ob["geometry"]["coordinates"].push([])  #                     # replace the original coordinates
          #   ob["geometry"]["coordinates"].push([])  #                     # replace the original coordinates
          #   ob["geometry"]["coordinates"][0].push(coords_2)  #                     # replace the original coordinates
          #   ob["geometry"]["coordinates"][1].push(coords_1)  #                     # append first coordinates with second
          #   job = ob.as_json.to_s.gsub('=>', ':') #                           # change back to a feature string
          #   my_feature = RGeo::GeoJSON.decode(job, :json_parser => :json) #   # replicate "normal" steps above
          #   geometry = my_feature.geometry.as_text #                         # extract the WKT
          #  end
            @georeferences = Georeference.joins(:geographic_item).where(GeographicItem.contained_by_wkt_sql(geometry))
        else
      end
    if @georeferences.length == 0
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
