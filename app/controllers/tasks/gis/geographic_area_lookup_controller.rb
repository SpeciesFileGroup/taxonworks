class Tasks::Gis::GeographicAreaLookupController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
  end

  # GET /tasks/gis/geographic_area_lookup/resolve.js
  def resolve 
    @matches = GeographicArea.matching(params.require(:terms), has_shape_param) 
  end

  protected

  def has_shape_param
    begin
      true if params.require(:has_shape)
    rescue ActionController::ParameterMissing
      return false 
    end
  end

end
