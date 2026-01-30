class Tasks::Sources::DocumentsPackagerController < ApplicationController
  include TaskControllerConfiguration
  include Tasks::PackagerController
  include ZipTricks::RailsStreaming

  before_action -> { set_query_params_for(:source_query) }, only: [:preview, :download]

  # GET /tasks/sources/documents_packager
  def index
  end

  # POST /tasks/sources/documents_packager/preview.json
  def preview
    max_bytes = requested_max_bytes
    preview_data = packager.preview(max_bytes: max_bytes)

    render json: {
      sources: preview_data[:sources],
      groups: preview_data[:groups],
      filter_params: @query_params,
      total_documents: preview_data[:total_documents],
      max_bytes: max_bytes
    }
  end

  # POST /tasks/sources/documents_packager/download
  def download
    download_packager(
      packager: packager,
      group_index: params[:group].to_i,
      empty_message: 'No sources queued.',
      filename_prefix: 'TaxonWorks-sources_download'
    )
  end

  private

  def packager
    @packager ||= Export::Packagers::Documents.new(
      query_params: @query_params,
      project_id: sessions_current_project_id
    )
  end
end
