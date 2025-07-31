class Tasks::Leads::PrintController < ApplicationController
  include TaskControllerConfiguration

  before_action :set_lead

  def index
  end

  def table
  end

  private

  def set_lead
    @lead = Lead.where(project_id: sessions_current_project_id).find(params[:lead_id])
  end

end
