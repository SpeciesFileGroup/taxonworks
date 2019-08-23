class SqedDepictionsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def metadata_options 
  end

  def nearby
    @sqed_depiction = SqedDepiction.where(project_id: sessions_current_project_id).find(params[:id])
  end

end
