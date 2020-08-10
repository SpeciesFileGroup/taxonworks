class Tasks::DwcaImport::DwcaImportController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    respond_to do |format|
      format.html
      format.json {
        @datasets = ImportDataset::DarwinCore::Checklist
          .with_project_id(sessions_current_project_id)
          .order(:updated_at, :description)
          .page(params[:page]).per(params[:per] || 25)
      }
    end
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
