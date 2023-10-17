class Tasks::GeographicAreas::UsageController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    if params[:geographic_area_id].present?
      @geogrpahic_areas = GeographicArea.where(id: params[:geographic_area_id])
    else
      @geographic_areas = GeographicArea.all
    end

    if params[:geographic_item_id].present?
      @geographic_item = GeographicItem.find(params[:geographic_item_id])
    else
      @geographic_item = nil
    end
  end

end
