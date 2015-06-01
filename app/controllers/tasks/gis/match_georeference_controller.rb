class Tasks::Gis::MatchGeoreferenceController < ApplicationController

  def index
    # some things on to which to hang one's hat.
    @collecting_event  = CollectingEvent.new
    @georeference      = Georeference.new
    @collecting_events = []
    @georeferences     = []
  end

  def filtered_collecting_events
    @motion            = 'filtered_collecting_events'
    message            = ''
    prefix             = ''
    @collecting_events = CollectingEvent.filter(params) #

    # sql_string          = Utilities::Dates.date_sql_from_params(params)
    #
    # # processing text data
    # v_locality_fragment = params['verbatim_locality_text']
    # any_label_fragment  = params['any_label_text']
    # id_fragment         = params['identifier_text']
    #
    # unless v_locality_fragment.blank?
    #   unless sql_string.blank?
    #     prefix = ' and '
    #   end
    #   sql_string += "#{ prefix }verbatim_locality ilike '%#{v_locality_fragment}%'"
    # end
    # unless any_label_fragment.blank?
    #   unless sql_string.blank?
    #     prefix = 'and '
    #   end
    #   sql_string += "#{ prefix }(verbatim_label ilike '%#{any_label_fragment}%'"
    #   sql_string += " or print_label ilike '%#{any_label_fragment}%'"
    #   sql_string += " or document_label ilike '%#{any_label_fragment}%'"
    #   sql_string += ')'
    # end
    #
    # unless id_fragment.blank?
    #
    # end
    #
    # # find the records
    # unless sql_string.blank?
    #   @collecting_events = CollectingEvent.where(sql_string).uniq
    # end
    #
    if @collecting_events.length == 0
      message = 'no collecting events selected'
    end
    render_ce_select_json(message)
  end

  def recent_collecting_events
    @motion            = 'recent_collecting_events'
    message            = ''
    how_many           = params['how_many']
    @collecting_events = CollectingEvent.where(project_id: $project_id).order(updated_at: :desc).limit(how_many.to_i)
    if @collecting_events.length == 0
    else
      message = 'no recent objects selected'
    end
    render_ce_select_json(message)
  end

  def tagged_collecting_events
    @motion = 'tagged_collecting_events'
    message = ''
    if params[:keyword_id]
      keyword            = Keyword.find(params[:keyword_id])
      @collecting_events = CollectingEvent.where(project_id: $project_id).order(updated_at: :desc).tagged_with_keyword(keyword)
    else
      # You have to figure out how to catch a bad search request and return not a list but back to the form
      message = 'no tagged objects selected' #and return
    end
    render_ce_select_json(message)
  end

  def drawn_collecting_events
    @motion            = 'drawn_collecting_events'
    message            = ''
    @collecting_events = [] # replace [] with CollectingEvent.filter(params)
    render_ce_select_json(message)
  end

  def filtered_georeferences
    @motion        = 'filtered_georeference'
    message        = ''
    @georeferences = Georeference.filter(params)
    render_ce_select_json(message)
  end

  def recent_georeferences
    @motion        = 'recent_georeferences'
    message        = ''
    how_many       = params['how_many']
    @georeferences = Georeference.where(project_id: $project_id).order(updated_at: :desc).limit(how_many.to_i)
    if @georeferences.length == 0
      message = 'no recent georeferences selected'
    end
    render_gr_select_json(message)
  end

  def tagged_georeferences
    @motion = 'tagged_georeferences'
    message = ''

    # todo: this needs to be rationalized, but works, after a fashion.
    if params[:keyword_id].blank?
      # render json: {html: 'Empty set'} #and return
      @georeferences = []
      message        = 'no tagged objects selected'
    else
      keyword        = Keyword.find(params[:keyword_id])
      @georeferences = Georeference.where(project_id: $project_id).order(updated_at: :desc).tagged_with_keyword(keyword)
    end
    render_gr_select_json(message)
  end

  def drawn_georeferences
    @motion        = 'drawn_georeferences'
    message        = ''
    @georeferences = [] # replace [] with CollectingEvent.filter(params)
    value          = params['geographic_item_attributes_shape']
    feature        = RGeo::GeoJSON.decode(value, :json_parser => :json)
    # isolate the WKT
    geometry       = feature.geometry
    this_type      = geometry.geometry_type.to_s.downcase
    geometry       = geometry.as_text
    # pieces         = JSON.parse(value)
    radius         = feature['radius']
    case this_type
      when 'point'
        @georeferences = GeographicItem.within_radius_of_wkt('any', geometry, radius).map(&:georeferences).uniq.flatten
      when 'polygon'
        @georeferences = GeographicItem.are_contained_in_wkt('any', geometry).map(&:georeferences).uniq.flatten
      else
        @georeferences = Georeference.where('false')
    end


    # boundary       = GeographicItem.new
    # boundary.shape = params['geographic_item_attributes_shape']

    # receive shape from form:  polygon or circle, in 'geographic_item_attributes_shape'
    # create geographic_item object instance to match against?

    # @georeferences = GeographicItem.where('ST_contains()')
    # @georeferences =GeographicItem.are_contained_in('point', boundary)
    render_gr_select_json(message)
  end

  def batch_create_match_georeferences

    @motion = 'returning_results'
    respond_to do |format|
      format.json {
        # we want to repackage the checkmarks we get from the client side into an array of ids with which
        # to feed Georeference.
        keys        = params.keys
        checked_ids = []
        arguments   = {}
        keys.each { |key|
          if /check\d+/ =~ key
            checked_ids.push(params[key].to_i)
          end
        }
        arguments.merge!(georeference_id: params['georeference_id'])
        arguments.merge!(checked_ids: checked_ids)

        results = Georeference.batch_create_from_georeference_matcher(arguments)

        html = render_to_string(partial: 'georeference_success', formats: 'html',
                                locals:  {georeferences_results: results,
                                          motion:                @motion}
        )

        render json: {message: '',
                      html:    html
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
    retval = render json: {message: message, html: ce_render_to_html}
    retval
  end

  # @param [String] message to be conveyed to client side
  # @return [JSON] with html for georeferences display (feature collection)
  def render_gr_select_json(message)
    render json: {message: message, html: gr_render_to_html}
  end

  # @return [String] of html for partial
  def ce_render_to_html
    render_to_string(partial: 'tasks/gis/match_georeference/collecting_event_selections',
                     locals:  {collecting_events: @collecting_events,
                               motion:            @motion})
  end

  # @return [String] of html for partial
  def gr_render_to_html
    render_to_string(partial: 'tasks/gis/match_georeference/georeferences_selections_form',
                     locals:  {georeferences: @georeferences,
                               motion:        @motion})
  end

  def not_add_st_year(sql, st_year)
    unless st_year.blank?
      unless sql.blank?
        prefix = ' and '
      end
      sql += "#{prefix}(start_date_year = #{st_year})"
    end
    sql
  end

  def not_add_st_month(sql, st_month)
    unless st_month.blank?
      unless sql.blank?
        prefix = ' and '
      end
      sql += "#{prefix}(start_date_month = #{st_month})"
    end
    sql
  end

  def not_add_st_day(sql, st_day)
    unless st_day.blank?
      unless sql.blank?
        prefix = ' and '
      end
      sql += "#{prefix}(start_date_day = #{st_day})"
    end
    sql
  end

  def not_fix_time(year, month, day)
    start = Time.new(1970, 1, 1)
    if year.blank?
      year = start.year
    end
    if month.blank?
      month = start.month
    end
    if day.blank?
      day = start.day
    end
    Time.new(year, month, day)
  end

  # @return [String] of sql to test dates
  # @param [Hash] params
  def not_date_sql_from_params(params)
    st_date, end_date         = params['st_datepicker'], params['en_datepicker']
# processing start date data
    st_year, st_month, st_day = params['start_date_year'], params['start_date_month'], params['start_date_day']
    unless st_date.blank?
      parts                     = st_date.split('/')
      st_year, st_month, st_day = parts[2], parts[0], parts[1]
    end
    st_my                        = (!st_month.blank? and !st_year.blank?)
    st_m                         = (!st_month.blank? and st_year.blank?)
    st_y                         = (st_month.blank? and !st_year.blank?)
    st_blank                     = (st_year.blank? and st_month.blank? and st_day.blank?)
    st_full                      = (!st_year.blank? and !st_month.blank? and !st_day.blank?)
    st_partial                   = (!st_blank and (st_year.blank? or st_month.blank? or st_day.blank?))
    start_time                   = fix_time(params['start_date_year'],
                                            params['start_date_month'],
                                            params['start_date_day']) if st_full

# processing end date data
    end_year, end_month, end_day = params['end_date_year'], params['end_date_month'], params['end_date_day']
    unless end_date.blank?
      parts                        = end_date.split('/')
      end_year, end_month, end_day = parts[2], parts[0], parts[1]
    end
    end_my      = (!end_month.blank? and !end_year.blank?)
    end_m       = (!end_month.blank? and end_year.blank?)
    end_y       = (end_month.blank? and !end_year.blank?)
    end_blank   = (end_year.blank? and end_month.blank? and end_day.blank?)
    end_full    = (!end_year.blank? and !end_month.blank? and !end_day.blank?)
    end_partial = (!end_blank and (end_year.blank? or end_month.blank? or end_day.blank?))
    end_time    = fix_time(params['end_date_year'],
                           params['end_date_month'],
                           params['end_date_day']) if end_full

    sql_string = ''
# if all the date information is blank, skip the date testing
    unless st_blank and end_blank
      # only start and end year
      if st_y and end_y
        # start and end year may be different, or the same
        # we ignore all records which have a null start year,
        # but include all records for the end year test
        sql_string += "(start_date_year >= #{st_year} and (end_date_year is null or end_date_year <= #{end_year}))"
      end

      # only start month and end month
      if st_m and end_m
        # todo: This case really needs additional consideration
        # maybe build a string of included month and use an 'in ()' construct
        sql_string += "(start_date_month between #{st_month} and #{end_month})"
      end

      if end_blank # !st_blank = st_partial
        # if we have only a start date there are three cases: d/m/y, m/y, y
        if st_year.blank?
          sql_string = add_st_month(sql_string, st_month)
        else
          sql_string = add_st_day(sql_string, st_day)
          sql_string = add_st_month(sql_string, st_month)
          sql_string = add_st_year(sql_string, st_year)
        end
      else
        # end date only, don't do anything
      end

      if ((st_y or st_my) and (end_y or end_my)) and not (st_y and end_y)
        # we have two dates of some kind, complete with years
        # three specific cases:
        #   case 1: start year, (start month, (start day)) forward
        #   case 2: end year, (end month, (end day)) backward
        #   case 3: any intervening year(s) complete
        if st_year
        end
      end
    end
    sql_string
  end

end
