class Tasks::Sources::GnfinderController < ApplicationController
  include TaskControllerConfiguration

  before_action :set_object

  # GET /tasks/sources/gnfinder
  def index
    @result = Vendor::Gnfinder::Result.new(
      Vendor::Gnfinder.to_json( @document.pdftotext ),
      sessions_current_project_id)
  end

  private

  def set_object
    if @document = Document.where(project_id: sessions_current_project_id)
      .find_by(id: params[:document_id])
    elsif @source = Source.joins(:documents, :project_sources)
      .where(project_sources: {project_id: sessions_current_project_id})
      .find_by(id: params[:source_id])
    @document = @source.documents.first
    else
      redirect_to source_hub_task_path, notice: 'Source without Document or Document not found.' and return
    end
  end

end
