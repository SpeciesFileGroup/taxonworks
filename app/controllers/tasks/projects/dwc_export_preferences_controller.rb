class Tasks::Projects::DwcExportPreferencesController < ApplicationController
  include TaskControllerConfiguration

  def index
    @project = Project.find(sessions_current_project_id)
    @preferences = @project.preferences

    if request.post?
      @dataset_errors, @additional_metadata_errors =
        Export::Dwca::Eml.validate_fragments(
          params[:dataset], params[:additional_metadata]
        )

      if @dataset_errors.count + @additional_metadata_errors.count == 0
        rv = save_to_preferences(params[:dataset], params[:additional_metadata])
        if rv == false
          # TODO
        else
          flash[:notice] = 'Preferences saved'
          redirect_to @project
        end
      else
        @dataset = params[:dataset]
        @additional_metadata = params[:additional_metadata]
        render :index, status: :unprocessable_entity
      end
    elsif request.get?
      # check for preferences
      @dataset = default_dataset
      @additional_metadata = default_additional_metadata
    end
  end

  private

  def save_to_preferences(dataset, additional_metadata)
    project = Project.find(sessions_current_project_id)
    preferences = project.preferences
    xml = eml_template
    xml = xml.sub('@dataset', dataset)
    # TODO: need to insert <dateStamp>2025-08-24T23:42:58-05:00</dateStamp>
    xml = xml.sub('@additional_metadata', additional_metadata)
    eml_xml = Nokogiri::XML::Document.parse(xml)
    return false if eml_xml.errors.present?

    preferences[:eml] = xml
    return project.save
  end

  def xml_errors(dataset, additional_metadata)
    # TODO: currently fails on namespaced prefixes like 'dc:replaces'
    dataset_xml = Nokogiri::XML::Document.parse(
      eml_template_one_line.sub('@dataset', dataset)
    )

    additional_metadata_xml = Nokogiri::XML::DocumentFragment.parse(
      eml_template_one_line.sub('@additional_metadata', additional_metadata)
    )

    [dataset_xml.errors, additional_metadata_xml.errors]
  end


end