class Labels::FactoryController < ApplicationController
 # include DataControllerConfiguration::ProjectDataControllerConfiguration

  def unit_tray_header1
    if c = Press::Labels.unit_tray_header1(params.require(:taxon_name_id))
      render json: {created: c} 
    else
      render json: {error: 'Error creating labels'}, status: :unprocessable_entity 
    end 
  end
  
end
