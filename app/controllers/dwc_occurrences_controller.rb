class DwcOccurrencesController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :require_administrator_sign_in, only: [:sweep]
  before_action :set_object, only: [:status, :create]

  after_action -> { set_pagination_headers(:dwc_occurrences) }, only: [:index, :api_index], if: :json_request?

  # .json only
  def index
    @dwc_occurrences = Queries::DwcOccurrence::Filter.new(params).all
      .where(project_id: sessions_current_project_id)
      .page(params[:page])
      .per(params[:per] || 1)
  end

  def api_index
    q = Queries::DwcOccurrence::Filter.new(params.merge!(api: true)).all
      .where(project_id: sessions_current_project_id)
      .page(params[:page]).per(params[:per])

    respond_to do |format|
      format.json {
        @dwc_occurrences = q
        render '/dwc_occurrences/api/v1/index'
      }
      format.csv {
        @dwc_occurrences = q.limit(100000)
        send_data Export::CSV.generate_csv(
          @dwc_occurrences,
          exclude_columns: %w{updated_by_id created_by_id project_id, is_flagged_for_rebuild},
        ), type: 'text', filename: "dwc_occurrences_#{DateTime.now}.tsv"
      }
    end
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

  # GET /dwc_occurence/download
  def download
    send_data Export::CSV.generate_csv(
      DwcOccurrence.where(project_id: sessions_current_project_id)), type: 'text', filename: "dwc_occurrence_#{DateTime.now}.tsv"
  end

  # POST /dwc_occurrence/sweep (admin)
  def sweep
    DwcOccurrence.sweep
    redirect_to administration_data_health_task_path and return
  end

  # TODO: extract this all, unify with Concerns::IsData model, and re-use in DwcOccurrence
  def attributes
    i = Queries::DwcOccurrence::Filter::ATTRIBUTES
    render json:  ::DwcOccurrence.columns.select{
      |a| i.include?(a.name.to_sym)
    }.collect{|b| {'name' => b.name, 'type' => b.type } }
  end

  protected

  def set_object
    @object = GlobalID::Locator.locate(params[:object_global_id])

    if @object.nil? || (@object.project_id != sessions_current_project_id)
      render status: :not_found and return
    end
  end

end
