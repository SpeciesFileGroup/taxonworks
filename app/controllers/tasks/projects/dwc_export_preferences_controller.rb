class Tasks::Projects::DwcExportPreferencesController < ApplicationController
  include TaskControllerConfiguration

  def index
    @project = Project.find(sessions_current_project_id)
    @preferences = @project.preferences

    if request.post?
      @dataset_errors, @additional_metadata_errors =
        xml_errors(params[:dataset], params[:additional_metadata])

      if @dataset_errors.count + @additional_metadata_errors.count == 0

      else
        @dataset = params[:dataset]
        @additional_metadata = params[:additional_metadata]
        render :index, status: :unprocessable_entity
      end
    end
  end

  private

  def xml_errors(dataset, additional_metadata)
    dataset_xml = Nokogiri::XML::Document.parse(dataset)

    additional_metadata_xml = Nokogiri::XML::Document.parse(additional_metadata)

    [dataset_xml.errors, additional_metadata_xml.errors]
  end
end