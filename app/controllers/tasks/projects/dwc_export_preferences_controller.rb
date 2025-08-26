class Tasks::Projects::DwcExportPreferencesController < ApplicationController
  include TaskControllerConfiguration

  def index
    @project = Project.find(sessions_current_project_id)
    @preferences = @project.preferences
  end

  def gbif_metadata_validate
    dataset_xml = Nokogiri::XML::Document.parse(params[:dataset])

    additional_metadata_xml = Nokogiri::XML::Document.parse(params[:additional_metadata])

    @errors = dataset_xml.errors.map { |e| "dataset: #{e}"} +
      additional_metadata_xml.errors.map { |e| "additional_metadata: #{e}"}

    if @errors.present?
      @dataset = params[:dataset]
      @additional_metadata = params[:additional_metadata]
      render :index, status: :unprocessable_entity
    end
  end
end