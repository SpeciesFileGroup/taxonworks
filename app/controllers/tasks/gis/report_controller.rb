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
    selected_headers   = {prefixes: [], headers: [], types: []}
    case params[:commit]
      when 'Show'
        # #1, gather up all the headers, and pull out the ones which were selected (if any)
        all_headers = params[:headers]
        all_headers.keys.each { |h_key|
          list = all_headers[h_key]
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
        # remove all the headers which are NOT checked
        %w(ce co bc).each { |column|
          group = all_headers[column.to_sym]
          group.keys.each { |type|
            headers = group[type.to_sym]
            unless headers.empty?
              headers.keys.each { |header|
                check = headers[header][:checked]
                unless check == '1'
                  all_headers[column.to_sym][type.to_sym].delete(header)
                end
              }
            end
          }
        }
        selected_headers       = all_headers # now the headers are the selected ones
        # session[:co_selected_headers] = selected_headers
        @selected_column_names = selected_headers
        gather_data(geographic_area_id)
      when 'download'
        gather_data(params[:download_geo_area_id])
        # selected_headers = session[:co_selected_headers]
        selected_headers = params[:headers]

        report_file = CollectionObject.generate_report_download(@collection_objects, selected_headers)
        send_data(report_file, type: 'text', filename: "collection_objects_report_#{DateTime.now.to_s}.csv")
      # and return
      else
    end
    selected_headers
  end

  def gather_data(geographic_area_id)
    @geographic_area = GeographicArea.find(geographic_area_id)
    if @geographic_area.has_shape?
      @collection_objects = CollectionObject.in_geographic_item(@geographic_area.default_geographic_item).order(:id)
    else
      @collection_objects = CollectionObject.where('false')
    end
  end

  # def download
  #   @geographic_area    = GeographicArea.find(params[:geographic_area_id])
  #   @collection_objects = CollectionObject.in_geographic_item(@geographic_area.default_geographic_item)
  #   send_data CollectionObject.generate_report_download(@collection_objects, session[:co_selected_headers]), type: 'text', filename: "collection_objects_report_#{DateTime.now.to_s}.csv"
  # end
end
