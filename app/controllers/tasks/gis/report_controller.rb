class Tasks::Gis::ReportController < ApplicationController
  include TaskControllerConfiguration

  # before_action :disable_turbolinks, only: [:new, :generate_choices]

  # GET report
  def new
    @list_collection_objects = [] # CollectionObject.where('false')
    session.delete('co_selected_headers')
  end

  # POST location_report_list
  def location_report_list
    geographic_area_ids = params[:geographic_area_ids]
    current_headers     = params[:hd]
    shape_in            = params[:drawn_area_shape]
    finding             = params[:selection_object]
    current_page        = params[:page]
    # current_action      = params[:action]

    # case current_action
    #   when 'location_report_list'
    #   when 'repaint'
    # end
    case params[:commit]
      when 'Show'
        select_table_page(geographic_area_ids, shape_in, current_headers, finding, current_page)
      when 'download'
        # fixme: repair this: it aborts use of Redis, and forces load of all data
        test_redis_not = false
        table_data     = nil
        unless test_redis_not
          # TODO: This needs to be cleaned up and consolidated
          # check Redis mem-store for a valid result
          if test_redis
            table_name = sessions_current_user.email + '-c_o_table_data'
            table_data = JSON.parse(@c_o_table_store.get(table_name))
            # remove the selected data from Redis mem-store
            @c_o_table_store.set(table_name, '')
          else
            table_data = nil
          end

          table_data = nil
        end

        @list_collection_objects = GeographicItem.gather_selected_data(geographic_area_ids,
                                                                       shape_in,
                                                                       finding)
        report_file              = CollectionObject.generate_report_download(@list_collection_objects, current_headers, table_data)
        send_data(report_file, type: 'text', filename: "collection_objects_report_#{DateTime.now.to_s}.csv")
      else
        # what else is there to do?
    end
    # current_headers
  end

  def test_redis
    retval           = true
    @c_o_table_store = Redis.new

    begin
      @c_o_table_store.ping
    rescue Exception => e
      @c_o_table_store = nil
      retval           = false
      e.inspect
      e.message
      # puts "#{e.inspect}"
      # e.inspect
    end

    retval
  end

  def gather_data_x(geographic_area_id, include_page)
    return if geographic_area_id.blank?
    @geographic_area = GeographicArea.joins(:geographic_items).find(geographic_area_id)
    total_records    = CollectionObject.count
    limit            = include_page ? 25 : total_records
    # params[:page] = 2
    if @geographic_area.has_shape?
      @all_collection_objects_count = CollectionObject.where(project_id: sessions_current_project_id)
                                        .in_geographic_item(@geographic_area.default_geographic_item, total_records).count
      if include_page
        @list_collection_objects = CollectionObject.where(project_id: sessions_current_project_id)
                                     .in_geographic_item(@geographic_area.default_geographic_item, limit)
                                     .order(:id)
                                     .page(params[:page])
      else
        @list_collection_objects = CollectionObject.where(project_id: sessions_current_project_id)
                                     .in_geographic_item(@geographic_area.default_geographic_item, limit)
                                     .order(:id)
      end
    else
      @all_collection_objects_count = 0
      @list_collection_objects      = CollectionObject.where('false')
    end
    @list_collection_objects
  end

  def gather_area_data_x(shape_in, include_) # this will be a feature or feature collection
    if shape_in.blank?
      #   case finding
      #     when 'collection_object'
      @list_collection_objects = CollectionObject.where('false')
      #     else
      #   end
    else
      feature = RGeo::GeoJSON.decode(shape_in, :json_parser => :json)
      # isolate the WKT
      geometry  = feature.geometry
      this_type = geometry.geometry_type.to_s.downcase
      geometry  = geometry.as_text
      radius    = feature['radius']
      # case finding
      #   when 'collection_object'
      case this_type
        when 'point'
          @list_collection_objects = CollectionObject
                                       .joins(:geographic_items)
                                       .where(project_id: sessions_current_project_id)
                                       .where(GeographicItem.within_radius_of_wkt_sql(geometry, radius))
                                       .page(params[:page])
        when 'polygon'
          @list_collection_objects = CollectionObject
                                       .joins(:geographic_items)
                                       .where(project_id: sessions_current_project_id)
                                       .where(GeographicItem.contained_by_wkt_sql(geometry))
                                       .page(params[:page])
        else
      end
      # else
      # end
    end
  end

  # GET location_report_list
  def repaint
    session.delete('co_selected_headers')
    select_table_page(params[:geographic_area_ids],
                      params[:drawn_area_shape],
                      params[:hd],
                      params[:selection_object],
                      params[:page])
    # remove the list from the session so that they are not included in the links generated by pagination
    render 'location_report_list'
    # render 'repaint'
  end

  protected

  def select_table_page(geographic_area_ids, shape_in, current_headers, finding, current_page)
    # remove all the headers which are NOT checked
    %w(ce co bc).each { |column|
      group = current_headers[column.to_sym]
      group.keys.each { |type|
        headers = group[type.to_sym]
        entry   = current_headers[column.to_sym][type.to_sym]
        unless headers.empty?
          headers.keys.each { |header|
            if headers[header].empty?
              # we must be in 'get' processing
            else
              check = headers[header][:checked]
              # we are in 'post'
              if check == '1'
                entry[header] = nil # leave the key in place
              else
                entry.delete(header) # remove the key:value pair
              end
            end
          }
        end
      } unless group.nil?
    } unless current_headers.nil?
    # selected_headers               ||= {ce: {in: {}, im: {}}, # make sure all columns and types are present,
    #                                     co: {in: {}, im: {}}, # even if empty
    #                                     bc: {in: {}, im: {}}}
    @selected_column_names         = current_headers
    session['co_selected_headers'] = current_headers
    # get first 25 records
    @list_collection_objects = GeographicItem.gather_selected_data(geographic_area_ids,
                                                                   shape_in,
                                                                   finding).page(current_page)
  end
end
