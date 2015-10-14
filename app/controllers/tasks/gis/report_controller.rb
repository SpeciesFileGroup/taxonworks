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
        gather_data(geographic_area_id)
        # next step is to discover which of the additional headers have been checked
        @headers = []; @prefixes = []
        params.each_with_index { |item, index|
          case item[1].class.to_s
            when 'ActionController::Parameters'
              entry = item[1]
              key   = entry.keys[0]
              if entry[key] == '1'
                prefix = key.to_s[0, 3]
                header = key.to_s[3, key.length]
                @prefixes.push(prefix)
                @headers.push(header)
                index
              end
            else
          end
        }

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
