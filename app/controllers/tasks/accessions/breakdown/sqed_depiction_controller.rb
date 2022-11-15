class Tasks::Accessions::Breakdown::SqedDepictionController < ApplicationController
  include TaskControllerConfiguration

  before_action :set_sqed_depiction, except: [:todo_map]
  after_action -> { set_pagination_headers(:sqed_depictions) }, only: [:todo_map], if: :json_request?

  # /tasks/accessions/breakdown/sqed_depiction/todo_map
  def todo_map
    SqedDepiction.clear_stale_progress
    @sqed_depictions = 
      ::Queries::SqedDepiction::Filter.new(filter_params).all.where(project_id: sessions_current_project_id)
      .order(:id).page(params[:page]).per(50)
    respond_to do |format|
      format.html {}
      format.json {}
    end
  end

  # GET /tasks/accession/breakdown/depiction/:id # id is a collection_object_id !!
  def index
    @result = SqedToTaxonworks::Result.new(
      depiction_id: @sqed_depiction.depiction.id,
      namespace_id: params[:namespace_id]
    )

    @identifier_prototype = Identifier.prototype_identifier(sessions_current_project_id, sessions_current_user_id)
  end

  def update
    next_sqed_depiction = @sqed_depiction

    if @sqed_depiction.depiction.depiction_object.update(collection_object_params)
      flash[:notice] = 'Successfully updated'

      next_sqed_depiction =
        case params[:commit]
        when 'Save and next w/out data [n]'
          @sqed_depiction.next_without_data(true) # true handles stale settings
        when 'Save and next'
          @sqed_depiction.nearby_sqed_depictions(0, 1, true)[:after].first # true handles stale settings
        else
          @sqed_depiction
        end
    else
      flash[:alert] = 'Failed to update! ' + @sqed_depiction.depiction.depiction_object.errors.full_messages.join('; ').html_safe
    end

    namespace_id = (params[:lock_namespace] ? params[:collection_object][:identifiers_attributes]['0'][:namespace_id] : nil)

    redirect_to sqed_depiction_breakdown_task_path(next_sqed_depiction, namespace_id)
  end

  protected

  def collection_object_params
    params.require(:collection_object).permit(
      :buffered_collecting_event, :buffered_other_labels, :buffered_determinations, :total,
      identifiers_attributes: [:id, :namespace_id, :identifier, :type, :_destroy],
      tags_attributes: [:id, :keyword_id, :_destroy],
      taxon_determinations_attributes: [:id, :otu_id, :_destroy],
      notes_attributes: [:id, :text, :_destroy]
    )
  end

  def set_sqed_depiction
    @sqed_depiction = SqedDepiction.where(project_id: sessions_current_project_id).find(params[:id])
    @sqed_depiction.update_column(:in_progress, Time.now)
    # TODO: Run jobs in background with admin task.
    # @sqed_depiction.preprocess
  end

  private

  def filter_params
    a = params.permit(
      ::Queries::SqedDepiction::Filter::COLLECTION_OBJECT_FILTER_PARAMS,
      :recent,
      :user_date_end,
      :user_date_start,
      :user_id,
      :user_target,
    )

    # TODO: check user_id: []

    a[:user_id] = params[:user_id] if params[:user_id] && is_project_member_by_id(params[:user_id], sessions_current_project_id) # double check vs. setting project_id from API
    a
  end



end
