class Tasks::Accessions::Report::DwcController < ApplicationController
  include TaskControllerConfiguration

  def index 
    @collection_objects = CollectionObject.order(:id).includes(:dwc_occurrence).with_project_id(sessions_current_project_id).page(params[:page])
  end

  def row
    @dwc_occurrence = CollectionObject.includes(:dwc_occurrence).find(params[:id]).get_dwc_occurrence # find or compute for
  end

  def download
    send_data Download.generate_csv(
      DwcOccurrence.computed_columns.where(project_id: sessions_current_project_id), 
      trim_columns: true, 
      trim_rows: true,
      header_converters: [:dwc_headers]
    ), type: 'text', filename: "dwc_occurrences_#{DateTime.now.to_s}.csv"
  end

end
