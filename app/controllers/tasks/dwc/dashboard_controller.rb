class Tasks::Dwc::DashboardController < ApplicationController
  include TaskControllerConfiguration
  include CollectionObjects::FilterParams

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
    if collection_object_filter_params.to_h.any?
      a = DwcOccurrence.by_collection_object_filter(
        filter_scope: filtered_collection_objects,
        project_id: sessions_current_project_id)
    else
      a = DwcOccurrence.where(project_id: sessions_current_project_id)
      if params[:dwc_occurrence_start_date]
        a = a.where('dwc_occurrences.updated_at < ? and dwc_occurrences.updated_at > ?', params[:dwc_occurrence_start_date], params[:dwc_occurrence_end_date])
      end
    end

    # Param passing starts here.
    @download = ::Export::Dwca.download_async(a, request.url, predicate_extension_params: predicate_extension_params )
    render '/downloads/show'
  end

  def create_index
    if collection_object_filter_params.to_h.any?
      metadata = ::Export::Dwca.build_index_async(CollectionObject, filtered_collection_objects)
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
    params.permit(collecting_event_predicate_id: [], collection_object_predicate_id: [] )
  end


end
