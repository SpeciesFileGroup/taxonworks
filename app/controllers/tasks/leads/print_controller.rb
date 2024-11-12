class Tasks::Leads::PrintController < ApplicationController
  include TaskControllerConfiguration

  def index
    @lead = Lead.where(project_id: sessions_current_project_id).find(params[:lead_id])
  end

end
