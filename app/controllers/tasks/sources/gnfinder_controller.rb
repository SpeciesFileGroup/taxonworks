class Tasks::Sources::GnfinderController < ApplicationController
  include TaskControllerConfiguration

  before_action :set_object

  # GET /tasks/sources/gnfinder
  def index
    @result = Vendor::Gnfinder.result(
      @document.pdftotext,
      project_id: [sessions_current_project_id])
  end

  private

  def set_object
    source_query = Source.joins(:documents, :project_sources)
      .where(project_sources: {project_id: sessions_current_project_id})

    if @document = Document.where(project_id: sessions_current_project_id).find_by(id: params[:document_id])
      @source =  source_query.where(documents: {id: @document.id}).first
    elsif @source = source_query.find_by(id: params[:source_id])
      @document = @source.documents.first
    else
      redirect_to source_hub_task_path, notice: 'Source without Document or Document not found.' and return
    end
  end

end
