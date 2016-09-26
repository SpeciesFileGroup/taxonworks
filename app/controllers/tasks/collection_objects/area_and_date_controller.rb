class Tasks::CollectionObjects::AreaAndDateController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @geographic_areas   = GeographicArea.where('false')
    @collection_objects = CollectionObject.where('false')
    # @collection_objects = CollectionObject.limit(3)
  end

  # POST
  # find all of the objects within the supplied area and within the supplied data range
  def find
    message             = ''
    # area_objects = nil
    # date_objects = nil

    # find the objects in the selected area
    @geographic_area_id = params[:geographic_area_id]
    @geographic_area    = GeographicArea.find(@geographic_area_id) unless @geographic_area_id.blank?
    @shape_in           = params[:drawn_area_shape]
    @start_date         = params[:st_flexpicker].gsub('/', '-') # convert stipulated date format
    @end_date           = params[:en_flexpicker].gsub('/', '-') # to postgresql date format

    if @shape_in.blank? and @geographic_area_id.blank
      area_objects = CollectionObject.where('false')
    else
      area_objects = GeographicItem.gather_selected_data(@geographic_area_id, @shape_in, 'CollectionObject')
    end

    if (@start_date.blank? || @end_date.blank?) || area_objects.count == 0
      date_objects = CollectionObject.where('false')
    else
      area_list = area_objects.map(&:id).to_s.gsub('[', '(').gsub(']', ')')
      # @collection_objects = CollectionObject.find_by_sql("select * from collection_objects where id in #{area_list} AND created_at BETWEEN '#{@start_date}' AND '#{@end_date}' AND project_id = #{sessions_current_project_id}")
      @collection_objects = CollectionObject.where(id: area_objects.map(&:id)).where(created_at: @start_date.to_date..@end_date.to_date)
    end
    # @collection_objects = area_objects + date_objects

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
    @start_date               = params[:st_flexpicker].gsub('/', '-') # convert stipulated date format
    @end_date                 = params[:en_flexpicker].gsub('/', '-') # to postgresql date format
    # @collection_objects_count = CollectionObject.find_by_sql("select count(id) from collection_objects where id > 0 AND created_at BETWEEN '#{@start_date}' AND '#{@end_date}' AND project_id = #{sessions_current_project_id}").first.count
    @collection_objects_count = CollectionObject.where(:created_at => @start_date.to_date..@end_date.to_date).count
    render json: {html: @collection_objects_count.to_s}
    # integrate graph next
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

end
