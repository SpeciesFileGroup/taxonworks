class Tasks::Gis::ReportController < ApplicationController
  include TaskControllerConfiguration

  # before_action :disable_turbolinks, only: [:new, :generate_choices]


  def self.report_file
    @report_file = [CO_OTU_Strings.split(',')]
    @report_file
  end

  def new
    @collection_objects = CollectionObject.where('false')
  end

  def location_report_list

    geographic_area_id = params[:geographic_area_id]
    case params[:commit]
      when 'Show'
        selected_headers = {prefixes: [], headers: [], types: []}
        gather_data(geographic_area_id)
        # next step is to discover which of the additional headers have been checked
        headers = params[:headers]
        headers.keys.each { |h_key|
          list = headers[h_key]
          list.keys.each { |l_key|
            item = list[l_key]
            item.keys.each { |t_key|
              if item[t_key] == '1' # check_box was selected
                selected_headers[:prefixes].push(h_key)
                selected_headers[:headers].push(l_key)
                selected_headers[:types].push(t_key)
              end
            }
          }
        }
        session[:co_selected_headers] = selected_headers
      when 'download'
        gather_data(params[:download_geo_area_id])
        report_file = CollectionObject.generate_report_download(@collection_objects)
        send_data(report_file, type: 'text', filename: "collection_objects_report_#{DateTime.now.to_s}.csv")
      # and return
      else
    end
    # render :new
  end

  def gather_data(geographic_area_id)
    @geographic_area = GeographicArea.find(geographic_area_id)
    if @geographic_area.has_shape?
      @collection_objects = CollectionObject.in_geographic_item(@geographic_area.default_geographic_item)
    else
      @collection_objects = CollectionObject.where('false')
    end
  end

  # def download
  #   @geographic_area    = GeographicArea.find(params[:geographic_area_id])
  #   @collection_objects = CollectionObject.in_geographic_item(@geographic_area.default_geographic_item)
  #   send_data CollectionObject.generate_report_download(@collection_objects), type: 'text', filename: "collection_objects_report_#{DateTime.now.to_s}.csv"
  # end
end
