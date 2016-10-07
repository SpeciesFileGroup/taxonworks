class Tasks::CollectionObjects::AreaAndDateController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @geographic_areas   = GeographicArea.where('false')
    @collection_objects = CollectionObject.where('false')
    @early_date         = CollectionObject.order(:created_at).limit(1).pluck(:created_at).first
    @late_date          = CollectionObject.order(created_at: :desc).limit(1).pluck(:created_at).first
  end

  # POST
  # find all of the objects within the supplied area and within the supplied data range
  def find
    message             = ''
    # find the objects in the selected area
    @geographic_area_id = params[:geographic_area_id]
    @geographic_area    = GeographicArea.find(@geographic_area_id) unless @geographic_area_id.blank?
    @shape_in           = params[:drawn_area_shape]
    set_and_order_dates(params)

    if @shape_in.blank? and @geographic_area_id.blank? # missing "? "
      area_objects = CollectionObject.where('false')
    else
      area_objects = GeographicItem.gather_selected_data(@geographic_area_id, @shape_in, 'CollectionObject')
    end

    if (@start_date.blank? || @end_date.blank?) || area_objects.count == 0
      @collection_objects = CollectionObject.where('false')
    else
      collecting_events   = CollectingEvent.in_date_range_sql(params)
      @collection_objects = CollectionObject.includes(:collecting_event)
                              .where(collecting_event_id: collecting_events)
                              .where(id: area_objects.map(&:id))
    end

    @collection_objects_count = @collection_objects.count
    @feature_collection       = ::Gis::GeoJSON.feature_collection(find_georeferences_for(@collection_objects,
                                                                                         @geographic_area))
    message                   = 'No collection objects found.' if @collection_objects_count == 0
    render_co_select_json(message)
  end

  # GET
  def set_area
    @geographic_area_id       = params[:geographic_area_id]
    @shape_in                 = params[:drawn_area_shape]
    @collection_objects_count = GeographicItem.gather_selected_data(@geographic_area_id, @shape_in, 'CollectionObject').count

    render json: {html: @collection_objects_count.to_s}
  end

  # GET
  def set_date
    set_and_order_dates(params)
    # range_sql = CollectingEvent.date_sql_from_dates(@start_date, @end_date, false)
    collecting_events         = CollectingEvent.in_date_range_sql(params)
    @collection_objects       = CollectionObject.includes(:collecting_event)
                                  .where(collecting_event_id: collecting_events)
    @collection_objects_count = @collection_objects.count
    chart                     = render_to_string(partial: 'stats',
                                                 locals:  {count:   @collection_objects_count,
                                                           objects: @collection_objects})
    # render json: {html: @collection_objects_count.to_s, chart: @collection_objects.data_breakdown_for_chartkick_recent}
    render json: {html: @collection_objects_count.to_s, chart: chart}
    # render json: {html: @collection_objects_count.to_s}
  end

  def download_result

  end

  def gather_data

  end

  def render_co_select_json(message)
    render json: {message:                  message,
                  html:                     co_render_to_html,
                  feature_collection:       @feature_collection,
                  collection_objects_count: @collection_objects_count.to_s}
  end

  def co_render_to_html
    render_to_string(partial: 'tasks/accessions/report/dwca/table',
                     locals:  {collection_objects: @collection_objects}
    )
  end

  def find_georeferences_for(collection_objects, geographic_area)
    retval = collection_objects.map(&:collecting_event).uniq.map(&:georeferences).flatten
    if retval.empty?
      retval.push(geographic_area)
    end
    retval
  end

  def set_and_order_dates(params)
    @start_date = params[:st_flexpicker]
    @end_date = params[:en_flexpicker]
    if (@start_date > @end_date)
      params[:st_flexpicker] = @end_date
      params[:en_flexpicker] = @start_date
      @start_date = params[:st_flexpicker]
      @end_date = params[:en_flexpicker]
    end

  end

end
