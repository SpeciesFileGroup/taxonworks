class Tasks::Gis::GeographicAreaLookupController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
  end

  # GET /tasks/gis/geographic_area_lookup/resolve.js
  def resolve 
    begin
      @matches = GeographicArea.matching(params.require(:terms), has_shape_param, invert_param) 
    rescue ActionController::ParameterMissing
      @matches = []
    end
  end

  protected

  def invert_param
    begin
      true if params.require(:invert)
    rescue ActionController::ParameterMissing
      return false 
    end
  end

  def has_shape_param
    begin
      true if params.require(:has_shape)
    rescue ActionController::ParameterMissing
      return false 
    end
  end

end
