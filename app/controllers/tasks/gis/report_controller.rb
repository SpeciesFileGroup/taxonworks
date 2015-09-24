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

end
