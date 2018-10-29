class Tasks::Otus::BrowseController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    if params[:otu_id]
      @otu = Otu.where(project_id: sessions_current_project_id).find(params.require(:otu_id))
    else
      @otu = Otu.where(project_id: sessions_current_project_id).first
    end
    redirect_to new_otu_path, notice: 'No OTUs created, add one first.' and return if @otu.nil?
  end

end
