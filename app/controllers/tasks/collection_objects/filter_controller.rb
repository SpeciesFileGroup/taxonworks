
class Tasks::CollectionObjects::FilterController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @collection_objects = CollectionObject.none
  end

  def filter_params
    params.permit(:geographic_area_id, :drawn_area_shape)
  end

  # POST
  # find all of the objects within the supplied area and within the supplied data range
  def find
    message             = ''


    @collection_objects = CollectionObject.none
    message                   = 'No collection objects found.' if @collection_objects.count == 0
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
  def set_otu
    @otu_id     = params[:otu_id]
    descendants = params[:descendants]
    gather_otu_objects(@otu_id, descendants)
    render json: {html: @otu_collection_objects_count.to_s}
  end

  # @param [Integer] otu_id: an id for the selected otu
  # @param [String] descendants: 'on' for inclusion of other otus attached to the taxon_name (if available)
  #                              'off' to limit to the collection objects of this otu only
  def gather_otu_objects(otu_id, descendants)
    @otu = Otu.joins(:collecting_events).where(id: otu_id).first
    if @otu.nil?
      @otu_collection_objects = CollectionObject.none
    else
      if descendants.downcase == 'off' or @otu.taxon_name.blank?
        @otu_collection_objects = @otu.collection_objects
      else
        @otu_collection_objects = CollectionObject.joins(:taxon_names)
                                    .where(taxon_names: {id: @otu.taxon_name.self_and_descendants})
      end
    end
    @otu_collection_objects_count = @otu_collection_objects.count
  end

  def render_co_select_package(message)
    {message:                  message,
     feature_collection:       @feature_collection,
     collection_objects_count: @collection_objects.count.to_s}
  end

  def render_co_select_json(message)
    render json: {message:                  message,
                  html:                     co_render_to_html,
                  feature_collection:       @feature_collection,
                  collection_objects_count: @collection_objects.count.to_s}
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
    @start_date, @end_date     = Utilities::Dates.normalize_and_order_dates(params[:search_start_date],
                                                                            params[:search_end_date])
    params[:search_start_date] = @start_date
    params[:search_end_date]   = @end_date
  end

  protected

  def date_range_params
    params.permit('search_start_date', 'search_end_date', 'partial_overlap').to_h.symbolize_keys
  end

end
