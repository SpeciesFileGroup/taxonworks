class Tasks::DwcaImport::DwcaImportController < ApplicationController
  include TaskControllerConfiguration

  # GET
  def index
  end

  # POST
  def upload
    id = SecureRandom.urlsafe_base64
    base_path = Rails.root.join('dwca-storage', Current.project_id.to_s, id)
    source_path = base_path.join('source.csv')
    
    FileUtils.mkdir_p(base_path)
    File.write(source_path, params[:dwc_import][:file].tempfile.read)
    
    render json: { id: id, name: params[:name], core_table: stub }
  end

  # GET
  def workbench
    #base_path = Rails.root.join('dwca-storage', Current.project_id.to_s, params[:id])
    #source_path = base_path.join('source.csv')

    render json: { id: params[:id], name: "Mocked import", core_table: mock }
  end

private

  def mock
    JSON.parse(File.read(Rails.root.join('spec/files/dwca/dwca_sample.json')))
  end

  def dwc_import_params
    params.require(:dwc_import).permit(
      :file, :name
    )
  end
end
