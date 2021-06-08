class Tasks::Accessions::Report::DwcController < ApplicationController
  include TaskControllerConfiguration

  # tasks/accessions/report/dwc
  def index 
    respond_to do |format|
      format.html do
        @collection_objects = CollectionObject.order(:id).includes(:dwc_occurrence).with_project_id(sessions_current_project_id).page(params[:page]).per(params[:per] || 30)
      end

      # TODO: this is replaced with /collection_objects/report
      format.json {
        # TEMPORARY HACK! To be resolved with proper filter params at some points
        # Currently only used in digitize recent modal
        @collection_objects = CollectionObject.where(project_id: sessions_current_project_id).order(updated_at: :desc).includes(:dwc_occurrence).page(params[:page]).per(params[:per] || 30)
      }
    end
  end

  def row
    @dwc_occurrence = CollectionObject.includes(:dwc_occurrence).find(params[:id]).get_dwc_occurrence # find or compute for
  end

  def download
    # If failing remove begin/ensure/end to report Raised errors
    # TODO: integrate with Download
    
    begin
      data = ::Export::Dwca::Data.new(core_scope: DwcOccurrence.where(project_id: sessions_current_project_id))
      send_data(data.zipfile, type: 'application/zip', filename: data.filename)
    ensure
      data&.cleanup
    end
  end

end
