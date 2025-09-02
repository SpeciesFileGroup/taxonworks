class Tasks::Projects::DwcExportPreferencesController < ApplicationController
  include TaskControllerConfiguration
  before_action :require_administrator_sign_in

  before_action :set_project

  def index
    # vue app
  end

  def set_is_public
    @project.set_complete_dwc_download_is_public(params[:is_public])

    head :no_content
  end

  def validate_eml
    dataset = params[:dataset]
    additional_metadata = params[:additional_metadata]

    # if ::Export::Dwca::Eml.still_stubbed?(dataset, additional_metadata)
    #   render json: {
    #     base: ['Replace or delete all STUBbed fields to proceed']
    #   }, status: :unprocessable_entity
    #   return
    # end

    dataset_errors, additional_metadata_errors =
      ::Export::Dwca::Eml.validate_fragments(dataset, additional_metadata)

    render json: {
      dataset_errors:,
      additional_metadata_errors:
    }
  end

  def save_eml
    dataset = params[:dataset]
    additional_metadata = params[:additional_metadata]
    if @project.save_complete_dwc_eml_preferences(dataset, additional_metadata)
      head :no_content
    else # preferences save errors
      # It's probably a bug if this happens.
      render json: {
        base: ['Project save failed!']
      }
      return
    end
  end

  def preferences
    render json: @project.dwc_complete_download_preferences
  end

  private

  def set_project
    @project = Project.find(sessions_current_project_id)
    @recent_object = @project
  end
