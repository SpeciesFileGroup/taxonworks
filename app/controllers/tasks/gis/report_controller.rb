class Tasks::Gis::ReportController < ApplicationController
  include TaskControllerConfiguration

  # before_action :disable_turbolinks, only: [:new, :generate_choices]

  def new
    @collection_objects = CollectionObject.where('false')
  end

  def location_report_list
    geographic_area_id = params[:geographic_area_id]
    selected_headers   = params[:headers]
    case params[:commit]
      when 'Show'
        # remove all the headers which are NOT checked
        %w(ce co bc).each { |column|
          group = selected_headers[column.to_sym]
          group.keys.each { |type|
            headers = group[type.to_sym]
            unless headers.empty?
              headers.keys.each { |header|
                check = headers[header][:checked]
                unless check == '1'
                  selected_headers[column.to_sym][type.to_sym].delete(header)
                end
              }
            end
          }
        }
        @selected_column_names = selected_headers
        gather_data(geographic_area_id)
      when 'download'
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

        gather_data(params[:download_geo_area_id])
        report_file = CollectionObject.generate_report_download(@collection_objects, selected_headers, table_data)
        send_data(report_file, type: 'text', filename: "collection_objects_report_#{DateTime.now.to_s}.csv")
      else
    end
    selected_headers
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

  def gather_data(geographic_area_id)
    @geographic_area = GeographicArea.find(geographic_area_id)
    if @geographic_area.has_shape?
      @collection_objects = CollectionObject.in_geographic_item(@geographic_area.default_geographic_item).order(:id)
    else
      @collection_objects = CollectionObject.where('false')
    end
  end
end
