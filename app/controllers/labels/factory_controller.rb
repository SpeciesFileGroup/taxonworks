class Labels::FactoryController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def unit_tray_header1
    if Press::Labels.unit_tray_header(params.require(:taxon_name_id))
      render json: @label.errors, status: :unprocessable_entity 
    else
      render json: @label.errors, status: :unprocessable_entity 
    end 
  end
  
end
