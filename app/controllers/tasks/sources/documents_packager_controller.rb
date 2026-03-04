class Tasks::Sources::DocumentsPackagerController < ApplicationController
  include TaskControllerConfiguration
  include Tasks::PackagerController

  before_action :set_query_params, only: [:preview, :download]

  # GET /tasks/sources/documents_packager
  def index
  end

  # POST /tasks/sources/documents_packager/preview.json
  def preview
    preview_packager(
      packager: packager,
      payload_key: :sources
    )
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

  def set_query_params
    raw = params[:source_id]
    ids = raw.is_a?(ActionController::Parameters) ? raw.values : Array.wrap(raw).compact
    @query_params = ids.any? ? { source_id: ids }.with_indifferent_access : {}
  end

  def packager
    @packager ||= Export::Packagers::Documents.new(
      query_params: @query_params,
      project_id: sessions_current_project_id
    )
  end
end
