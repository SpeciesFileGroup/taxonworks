class Tasks::Gis::ReportController < ApplicationController
  include TaskControllerConfiguration

  # before_action :disable_turbolinks, only: [:new, :generate_choices]

  def new
    @list_collection_objects = [] # CollectionObject.where('false')
    session.delete('co_selected_headers')
  end

  def location_report_list
    geographic_area_id = params[:geographic_area_id]
    current_headers = params[:hd]
    value = params['drawn_map_shape']
    finding = params['selection_object']

    case params[:commit]
      when 'Show'
        # remove all the headers which are NOT checked
        %w(ce co bc).each { |column|
          group = current_headers[column.to_sym]
          group.keys.each { |type|
            headers = group[type.to_sym]
            entry = current_headers[column.to_sym][type.to_sym]
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
        @selected_column_names = current_headers
        session['co_selected_headers'] = current_headers
        gather_data(geographic_area_id, true) # get first 25 records
        # gather_area_data(value)
        if params[:page].nil?
        else
          # fail
        end
      when 'download'
        # fixme: repair this: it aborts use of Redis, and forces load of all data
        test_redis_not = false
        if test_redis_not == false
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

        gather_data(params[:download_geo_area_id], false) # gather all available data
        # gather_area_data(value)
        report_file = CollectionObject.generate_report_download(@list_collection_objects, current_headers, table_data)
        send_data(report_file, type: 'text', filename: "collection_objects_report_#{DateTime.now.to_s}.csv")
      else
    end
    current_headers
  end

  def test_redis
    retval = true
    @c_o_table_store = Redis.new

    begin
      @c_o_table_store.ping
    rescue Exception => e
      @c_o_table_store = nil
      retval = false
      e.inspect
      e.message
      # puts "#{e.inspect}"
      # e.inspect
    end

    retval
  end

  def gather_data(geographic_area_id, include_page)
    @geographic_area = GeographicArea.find(geographic_area_id)
    total_records = CollectionObject.all.count
    limit = include_page ? 25 : total_records
    # params[:page] = 2
    if @geographic_area.has_shape?
      @all_collection_objects_count = CollectionObject.where(project_id: $project_id).in_geographic_item(@geographic_area.default_geographic_item, total_records).count
      if include_page
        @list_collection_objects = CollectionObject.where(project_id: $project_id).in_geographic_item(@geographic_area.default_geographic_item, limit).order(:id).page(params[:page])
      else
        @list_collection_objects = CollectionObject.where(project_id: $project_id).in_geographic_item(@geographic_area.default_geographic_item, limit).order(:id)
      end
    else
      @all_collection_objects_count = 0
      @list_collection_objects = CollectionObject.where('false')
    end
    @list_collection_objects
  end

  def gather_area_data(value) # this will be a feature or feature collection
    if value.blank?
      #   case finding
      #     when 'collection_object'
      @list_collection_objects = CollectionObject.where('false')
      #     else
      #   end
    else
      feature = RGeo::GeoJSON.decode(value, :json_parser => :json)
      # isolate the WKT
      geometry = feature.geometry
      this_type = geometry.geometry_type.to_s.downcase
      geometry = geometry.as_text
      radius = feature['radius']
      # case finding
      #   when 'collection_object'
      case this_type
        when 'point'
          @list_collection_objects = Georeference.joins(:geographic_item).where(GeographicItem.within_radius_of_wkt_sql(geometry, radius))
        when 'polygon'
          @list_collection_objects = Georeference.joins(:geographic_item).where(GeographicItem.contained_by_wkt_sql(geometry))
        else
      end
      # else
      # end
    end
  end

  def repaint
    session.delete('co_selected_headers')
    location_report_list
    # remove the list from the session so that they are not included in the links generated by pagination
    render 'location_report_list'
  end

end
