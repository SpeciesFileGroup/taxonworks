class DwcOccurrencesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_object, only: [:status, :create]

  def metadata
    @dwc_occurrences = DwcOccurrence.where(project_id: sessions_current_project_id)
  end

  def predicates
  end

  def status
    if @object
      render json: {
        object: params[:object_global_id],
        id: @object.dwc_occurrence&.id,
        updated_at:  @object.dwc_occurrence&.updated_at
      }
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def collector_id_metadata
    render json: helpers.collector_global_id_metadata
  end

  def create
    respond_to do |format|
      format.html do
        @object.set_dwc_occurrence
        redirect_to browse_collection_objects_task_path(collection_object_id: @object.id)
      end
      format.json {
        render status: 302 and return
      }
    end
  end

  protected

  def set_object
    @object = GlobalID::Locator.locate(params[:object_global_id])

    if @object.nil? || (@object.project_id != sessions_current_project_id)
      render status: 404 and return
    end
  end

end
