class Tasks::CollectionObjects::AreaAndDateController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @geographic_areas         = GeographicArea.where('false')
    @collection_objects       = CollectionObject.where('false')
    @collection_objects_count = 0
    # TODO: Convert to dates from collecting events JDT
    # select distinct collecting_events.Start_date_year from collection_objects inner join collecting_events on collecting_event_id = collecting_events.id order by Start_date_year limit 100
    @early_date               = CollectionObject.where(project: sessions_current_project_id).order(:created_at).limit(1).pluck(:created_at).first
    if @early_date.blank?
      @early_date = Date.parse('1700/01/01')
    end
    @late_date = CollectionObject.where(project: sessions_current_project_id).order(created_at: :desc).limit(1).pluck(:created_at).first
    if @late_date.blank?
      @late_date = Date.today
    end
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

    area_set        = (@shape_in.blank? and @geographic_area_id.blank?) ? false : true

    if area_set
      area_object_ids = GeographicItem.gather_selected_data(@geographic_area_id,
                                                            @shape_in,
                                                            'CollectionObject').pluck(:id)
    else
      area_object_ids = []
    end

    if @start_date.blank? || @end_date.blank? #|| area_object_ids.count == 0
      @collection_objects = CollectionObject.where('false')
    else
      collecting_event_ids = CollectingEvent.in_date_range(date_range_params).pluck(:id)
      @collection_objects  = CollectionObject.from_collecting_events(collecting_event_ids,
                                                                     area_object_ids,
                                                                     area_set,
                                                                     sessions_current_project_id).page(params[:page])
    end

    @collection_objects_count = @collection_objects.count
    @feature_collection       = ::Gis::GeoJSON.feature_collection(find_georeferences_for(@collection_objects,
                                                                                         @geographic_area))
    message                   = 'No collection objects found.' if @collection_objects_count == 0
    @package                  = render_co_select_package(message)
    # render_co_select_json(message)
  end

  # GET
  # @return [Object] json object containing count
  def set_area
    @geographic_area_id       = params[:geographic_area_id]
    @shape_in                 = params[:drawn_area_shape]
    @collection_objects_count = GeographicItem.gather_selected_data(@geographic_area_id,
                                                                    @shape_in,
                                                                    'CollectionObject').count
    render json: {html: @collection_objects_count.to_s}
  end

  # GET
  # @return [Object] json object containing count and html of the chart
  def set_date
    set_and_order_dates(params)
    @collection_objects       = CollectionObject.in_date_range(date_range_params)
    @collection_objects_count = @collection_objects.count
    chart                     = render_to_string(partial: 'stats',
                                                 locals:  {count:   @collection_objects_count,
                                                           objects: @collection_objects})
    render json: {html: @collection_objects_count.to_s, chart: chart}
  end

  # GET
  def set_taxon_name
    @taxon_name_id            = params[:taxon_name_id]
    @taxon_name               = TaxonName.find(@taxon_name_id)
    @collection_objects       = CollectionObject.where('false')
    @collection_objects_count = @collection_objects.count
    render json: {html: @collection_objects_count.to_s}
  end

  def render_co_select_package(message)
    {message:                  message,
     feature_collection:       @feature_collection,
     collection_objects_count: @collection_objects_count.to_s}
  end

  def render_co_select_json(message)
    render json: {message:                  message,
                  html:                     co_render_to_html,
                  feature_collection:       @feature_collection,
                  collection_objects_count: @collection_objects_count.to_s}
  end

  def co_render_to_html
    render_to_string(partial: 'result_list',
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
    params      = CollectingEvent.normalize_and_order_dates(params)
    @start_date = params[:search_start_date]
    @end_date   = params[:search_end_date]
  end

  protected

  def date_range_params
    params.permit('search_start_date', 'search_end_date', 'partial_overlap').to_h.symbolize_keys
  end

end
