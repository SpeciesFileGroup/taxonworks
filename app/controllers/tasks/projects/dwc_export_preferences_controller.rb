class Tasks::Projects::DwcExportPreferencesController < ApplicationController
  include TaskControllerConfiguration

  def index
    @project = Project.find(sessions_current_project_id)
    @preferences = @project.preferences
    dataset = params[:dataset]
    additional_metadata = params[:additional_metadata]

    if request.post?
      if Export::Dwca::Eml.still_stubbed?(dataset, additional_metadata)
        #return error('Replace or delete all STUBbed fields to proceed')
      end

      @dataset_errors, @additional_metadata_errors =
        Export::Dwca::Eml.validate_fragments(dataset, additional_metadata)

      if @dataset_errors.count + @additional_metadata_errors.count == 0
        if @project.save_eml_preferences(dataset, additional_metadata)
          flash[:notice] = 'Preferences saved'
          redirect_to @project
        else # preferences save errors
          # It's probably a bug if this happens, we should maybe raise here.
          return error("Project save failed! #{@project.errors.full_messages.join(', ')}")
        end
      else # xml errors
        return error
      end
    elsif request.get?
      @dataset, @additional_metadata = @project.eml_preferences
      @dataset =
        @dataset || Export::Dwca::Eml.dataset_stub
      @additional_metadata =
        @additional_metadata || Export::Dwca::Eml.additional_metadata_stub
    end
  end

  private

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

  def error(message = nil)
    flash[:notice] = message if message.present?

    @dataset = params[:dataset]
    @additional_metadata = params[:additional_metadata]
    render :index, status: :unprocessable_entity
  end


end