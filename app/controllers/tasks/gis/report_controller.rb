class Tasks::Gis::ReportController < ApplicationController
  include TaskControllerConfiguration

  # before_action :disable_turbolinks, only: [:new, :generate_choices]

  def new
    @collection_objects = CollectionObject.where('false')
  end

  def location_report_list
    ga = GeographicArea.find(params[:geographic_area_id])
    if ga.has_shape?
      @collection_objects = CollectionObject.in_geographic_item(ga.default_geographic_item)
    else
      @collection_objects = CollectionObject.where('false')
    end
    render :new
  end

end
