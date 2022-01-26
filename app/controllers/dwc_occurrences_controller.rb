class DwcOccurrencesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_object, only: [:status, :create]

  after_action -> { set_pagination_headers(:dwc_occurrences) }, only: [:index, :api_index], if: :json_request?

  # .json only
  def index
    @dwc_occurrences = Queries::DwcOccurrence::Filter.new(filter_params).all
      .page(params[:page])
      .per(params[:per] || 1)
  end

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

  # TODO: remove
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

  # GET /api/v1/dwc_occurrences.json
  def api_index
    @dwc_occurrences = Queries::DwcOccurrence::Filter
      .new(api_params)
      .all
      .where(project_id: sessions_current_project_id)
      .page(params[:page]).per(params[:per] || 1)
    render '/dwc_occurrences/api/v1/index'
  end

  protected

  def api_params
    params.permit(
      :user_date_end,
      :user_date_start,

      # TODO: not a major risk, but perhaps
      # these need `token` proxy
      # :user_id,
      # :user_target,

      dwc_occurrence_id: [],
      dwc_occurrence_object_id: [],
      dwc_occurrence_object_type: []
    )
  end

  def filter_params
    params.permit(
      :user_date_end,
      :user_date_start,
      :user_id,
      :user_target,
      :dwc_occurrence_id,
      dwc_occurrence_id: [],
      dwc_occurrence_object_id: [],
      dwc_occurrence_object_type: []
    )
  end

  def set_object
    @object = GlobalID::Locator.locate(params[:object_global_id])

    if @object.nil? || (@object.project_id != sessions_current_project_id)
      render status: 404 and return
    end
  end

end
