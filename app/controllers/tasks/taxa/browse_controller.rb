class Tasks::Taxa::BrowseController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    if params[:otu_id]
    @otu = Otu.where(project_id: sessions_current_project_id).find(params.require(:otu_id))
    else
      @otu = Otu.where(project_id: sessions_current_project_id).first
    end
  end

end
