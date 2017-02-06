class Tasks::Accessions::Report::DwcController < ApplicationController
  include TaskControllerConfiguration

  def index 
    @collection_objects = CollectionObject.order(:id).includes(:dwc_occurrence).with_project_id(sessions_current_project_id).page(params[:page])
  end

  def row
    @dwc_occurrence = CollectionObject.includes(:dwc_occurrence).find(params[:id]).get_dwc_occurrence # find or compute for
  end

  def download
    # If failing remove begin/ensure/end to report Raised errors
    begin
      data = Dwca::Packer::Data.new(DwcOccurrence.where(project_id: sessions_current_project_id))
      send_data(data.getzip, :type => 'application/zip', filename: data.filename)
    ensure
      data.cleanup
    end
  end

end
