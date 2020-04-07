class Tasks::DwcaImport::DwcaImportController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
  end

  # POST
  def upload
  end

  # GET
  def workbench
    dataset = ImportDataset::DwcChecklist.find(params[:id])
    records = dataset.dataset_records

    render json: { id: params[:id], name: dataset.description, core_table: mock(records) }
  end

private

  def mock(records)
    headers = records.first.data_fields.keys
    rows = records.collect do |record|
      values = []
      headers.each { |h| values << record.data_fields[h]["value"] }

      values
    end

    {
      headers: headers,
      rows: rows
    }
  end

  def dwc_import_params
    params.require(:dwc_import).permit(
      :file, :name
    )
  end
end
