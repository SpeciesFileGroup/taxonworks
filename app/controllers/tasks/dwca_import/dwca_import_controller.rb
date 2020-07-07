class Tasks::DwcaImport::DwcaImportController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
  end

  # POST
  def upload
  end

private

  def dwc_import_params
    params.require(:dwc_import).permit(
      :file, :name
    )
  end
end
