class DwcOccurrencesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_object, only: [:status, :create]

  after_action -> { set_pagination_headers(:dwc_occurrences) }, only: [:index, :api_index], if: :json_request?

  # .json only
  def index
    @dwc_occurrences = Queries::DwcOccurrence::Filter.new(params).all
      .where(project_id: sessions_current_project_id)
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
        render status: :found and return
      }
    end
  end

  # GET /api/v1/dwc_occurrences.json
  def api_index
    @dwc_occurrences = Queries::DwcOccurrence::Filter.new(params.merge!(api: true))
      .all
      .where(project_id: sessions_current_project_id)
      .page(params[:page]).per(params[:per] || 1)
    render '/dwc_occurrences/api/v1/index'
  end

  # GET /dwc_occurence/download
  def download
    send_data Export::CSV.generate_csv(
      DwcOccurrence.where(project_id: sessions_current_project_id)), type: 'text', filename: "dwc_occurrence_#{DateTime.now}.tsv"
  end

  protected

  def set_object
    @object = GlobalID::Locator.locate(params[:object_global_id])

    if @object.nil? || (@object.project_id != sessions_current_project_id)
      render status: :not_found and return
    end
  end

end
