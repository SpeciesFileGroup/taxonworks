class Tasks::Gis::ReportController < ApplicationController
  include TaskControllerConfiguration

  # before_action :disable_turbolinks, only: [:new, :generate_choices]

  def new
    @collection_objects = CollectionObject.where('false')
  end

  def location_report_list
    @geographic_area = GeographicArea.find(params[:geographic_area_id])
    if @geographic_area.has_shape?
      @collection_objects = CollectionObject.in_geographic_item(@geographic_area.default_geographic_item)
    else
      @collection_objects = CollectionObject.where('false')
    end
    render :new
  end

  def download
    @geographic_area    = GeographicArea.find(params[:geographic_area_id])
    @collection_objects = CollectionObject.in_geographic_item(@geographic_area.default_geographic_item)
    send_data CollectionObject.generate_report_download(@collection_objects), type: 'text', filename: "collection_objects_report_#{DateTime.now.to_s}.csv"
  end
end
