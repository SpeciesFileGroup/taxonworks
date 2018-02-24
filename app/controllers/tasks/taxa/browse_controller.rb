class Tasks::Taxa::BrowseController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    @otu = Otu.where(project_id: sessions_current_project_id).find(params.require(:otu_id))
  end

end
