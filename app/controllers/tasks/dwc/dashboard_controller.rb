class Tasks::Dwc::DashboardController < ApplicationController
  include TaskControllerConfiguration

  # DWC_TASK
  def index
  end

  # /tasks/dwc/dashboard/generate_download.json
  # !! Run rails jobs:work in the terminal to complete builds
  def generate_download

    # TODO: to support scoping by other filters
    # we will have to scope all filter params throughout by their target base
    # e.g. collection_object[param]
    a = nil

    q = ::Queries::CollectionObject::Filter.new(params)
    q.project_id = nil

    if q.all(true)
      q.project_id = sessions_current_project_id
      a = DwcOccurrence.by_collection_object_filter(
        filter_scope: q.all,
        project_id: sessions_current_project_id)
    else
      a = DwcOccurrence.where(project_id: sessions_current_project_id)
      if params[:dwc_occurrence_start_date]
        a = a.where('dwc_occurrences.updated_at < ? and dwc_occurrences.updated_at > ?', params[:dwc_occurrence_start_date], params[:dwc_occurrence_end_date])
      end
    end

    @download = ::Export::Dwca.download_async(
      a, request.url,
      predicate_extensions: predicate_extension_params,
      extension_scopes: {
        biological_associations: params[:biological_associations_extension] ?
        ::Queries::BiologicalAssociation::Filter.new(collection_object_query: q.params).all.to_sql : nil
      }
    )
    render '/downloads/show'
  end

  # TODO: throttle to 5k.
  def create_index
    q = ::Queries::CollectionObject::Filter.new(params)
    q.project_id = nil

    if q.all(true)
      q.project_id = sessions_current_project_id
      metadata = ::Export::Dwca.build_index_async(CollectionObject, q.all)
      render json: metadata, status: :ok
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  def index_versions
    render json: ::Export::Dwca::INDEX_VERSION, status: :ok
  end

  private

  def predicate_extension_params
    params.permit(collecting_event_predicate_id: [], collection_object_predicate_id: [] ).to_h.symbolize_keys
  end

end
