class Tasks::DwcaImport::DwcaImportController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
    respond_to do |format|
      format.html
      format.json {
        @datasets = ImportDataset::DarwinCore
          .where(project_id: sessions_current_project_id)
          .order(:updated_at, :description)
          .page(params[:page]).per(params[:per] || 25)
      }
    end
  end

  # POST
  def upload
  end

  # POST
  def set_import_settings
    render json: ImportDataset::DarwinCore::Occurrences.find(params[:import_dataset_id]).set_import_settings(params[:import_settings])
  end

  # POST
  def update_catalog_number_namespace
    ImportDataset::DarwinCore::Occurrences
      .find(params[:import_dataset_id])
      .update_catalog_number_namespace(params[:institutionCode], params[:collectionCode], params[:namespace_id])

    render json: {success: true}
  end

private

  def dwc_import_params
    params.require(:dwc_import).permit(
      :file, :name
    )
  end
end
