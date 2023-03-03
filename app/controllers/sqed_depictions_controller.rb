class SqedDepictionsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def update
    @sqed_depiction = SqedDepiction.where(project_id: sessions_current_project_id).find(params[:id])
    @sqed_depiction.update(rebuild: true)
    redirect_to sqed_depiction_breakdown_task_path(@sqed_depiction), notice: 'Values recalculated.'
  end

  def metadata_options 
  end

end
