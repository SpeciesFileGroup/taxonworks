class Tasks::Projects::DwcExportPreferencesController < ApplicationController
  include TaskControllerConfiguration
  before_action :require_project_administrator_sign_in

  before_action :set_project

  def index
    # vue app
  end

  def set_max_age
    project = Project.find(sessions_current_project_id)
    if @project.set_complete_dwc_download_max_age(params[:max_age])
      head :no_content
    else
      render json: {
        base: 'Failed to interpret max age!'
      }, status: :unprocessable_entity
    end
  end

  def set_is_public
    @project.set_complete_dwc_download_is_public(params[:is_public])

    head :no_content
  end

  def set_default_user
    @project.set_complete_dwc_download_default_user_id(params[:default_user_id])

    head :no_content
  end

  def set_extensions
    @project.set_complete_dwc_download_extensions(params[:extensions])

    head :no_content
  end

  def set_predicates_and_internal_values
    @project.set_complete_dwc_download_predicates_and_internal_values(params[:predicates_and_internal_values])

    head :no_content
  end

  def validate_eml
    dataset = params[:dataset]
    additional_metadata = params[:additional_metadata]

    # dataset is required, additional_metadata is not
    if dataset.blank?
      render json: {
        errors: 'Dataset EML is required.'
      }, status: :unprocessable_entity
      return
    end

    if sessions_current_project.complete_dwc_download_is_public? &&
      ::Export::Dwca::Eml.still_stubbed?(dataset, additional_metadata)

      render json: {
        errors: ["Can't save EML with 'STUB' while download is public - either remove STUBs to save or make download private."]
      }, status: :unprocessable_entity
      return
    end

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
    if @project.set_complete_dwc_eml_preferences(dataset, additional_metadata)
      head :no_content
    else # preferences save errors
      # It's probably a bug if this happens.
      render json: {
        base: ['Project save failed!']
      }, status: :unprocessable_entity
      return
    end
  end

  def preferences
    render json: @project.dwc_complete_download_preferences(sessions_current_user)
  end

  private

  def set_project
    @project = Project.find(sessions_current_project_id)
    @recent_object = @project
  end
end
