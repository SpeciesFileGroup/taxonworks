class Tasks::Dwc::DashboardController < ApplicationController
  include TaskControllerConfiguration
  include CollectionObjects::FilterParams

  # DWC_TASK
  def index
  end

  # !! Run rails jobs:work in the terminal to complete builds
  def generate_download
    # TODO: to support scoping by other filters
    # we will have to scope all filter params throughout by their target base
    # e.g. collection_object[param]
    a = nil
    if collection_object_filter_params.to_h.any?
      a = DwcOccurrence
        .collection_objects_join
        .where(project_id: sessions_current_project_id)
        .merge(filtered_collection_objects)
    else
      a ||= DwcOccurrence.where(project_id: sessions_current_project_id).all
    end

    download = ::Export::Dwca.download_async(a, request.url)
    redirect_to file_download_path(download)
  end

  def create_index
    if collection_object_filter_params.to_h.any?
      metadata = ::Export::Dwca.build_index_async(CollectionObject, filtered_collection_objects)
      render json: metadata, status: :ok
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  private


end
