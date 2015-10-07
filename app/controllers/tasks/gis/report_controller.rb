class Tasks::Gis::ReportController < ApplicationController
  include TaskControllerConfiguration

  # before_action :disable_turbolinks, only: [:new, :generate_choices]


  def self.report_file
    @report_file = [CO_OTU_Strings.split(',')]
    @report_file
  end

  def new
    @collection_objects = CollectionObject.where('false')
    @with_ce            = true
    @with_co            = true
    @with_bc            = true
  end

  def location_report_list

    @with_ce           = params[:collecting_event_attributes] == 'on'
    @with_co           = params[:collection_object_attributes] == 'on'
    @with_bc           = params[:biological_classifications] == 'on'
    geographic_area_id = params[:geographic_area_id]
    case params[:commit]
      when 'Show'
        gather_data(geographic_area_id)
        session[:geographic_area_id] = geographic_area_id
      when 'download'
        gather_data(session[:geographic_area_id])
        report_file = CollectionObject.generate_report_download(@collection_objects, @with_ce, @with_co, @with_bc)
        send_data(report_file, type: 'text', filename: "collection_objects_report_#{DateTime.now.to_s}.csv") and return
      else
    end
    render :new
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
