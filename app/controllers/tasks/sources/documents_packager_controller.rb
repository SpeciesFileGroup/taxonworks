class Tasks::Sources::DocumentsPackagerController < ApplicationController
  include TaskControllerConfiguration
  include ZipTricks::RailsStreaming

  DEFAULT_MAX_BYTES = 1_000.megabytes
  MIN_MAX_BYTES = 10.megabyte
  MAX_MAX_BYTES = 1_000.megabytes

  before_action :set_query_params, only: [:preview, :download]

  # GET /tasks/sources/documents_packager
  def index
  end

  # POST /tasks/sources/documents_packager/preview.json
  def preview
    max_bytes = requested_max_bytes
    preview = packager.preview(max_bytes: max_bytes)

    render json: {
      sources: preview[:sources],
      groups: preview[:groups],
      filter_params: @query_params,
      total_documents: preview[:total_documents],
      max_bytes: max_bytes
    }
  end

  # GET /tasks/sources/documents_packager/download
  def download
    query_params = @query_params
    group_index = params[:group].to_i
    nickname = params[:nickname].to_s

    render json: { error: 'No sources queued.' }, status: :unprocessable_content and return if query_params.blank?

    max_bytes = requested_max_bytes
    groups = packager.groups(max_bytes: max_bytes)
    group = groups[group_index - 1]

    render json: { error: 'Group not found.' }, status: :not_found and return if group.blank?

    entries = group.map { |entry| entry[:document] }
    entries.select! { |document| streamer.document_source_available?(document) }

    render json: { error: 'No files available for this package.' }, status: :unprocessable_content and return if entries.empty?

    filename = build_zip_filename(nickname, group_index, groups.length)
    response.headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
    streamer.stream(entries: entries, zip_streamer: method(:zip_tricks_stream))
  end

  private

  def set_query_params
    @query_params = params[:source_query].presence || params
    @query_params = @query_params.to_unsafe_h if @query_params.respond_to?(:to_unsafe_h)
    @query_params = @query_params.except(
      'controller',
      'action',
      'format',
      'group',
      'nickname',
      'max_mb',
      'authenticity_token',
      'token'
    )
  end

  def requested_max_bytes
    mb = params[:max_mb].presence
    mb = mb.to_f if mb
    bytes = if mb && mb.positive?
              (mb * 1.megabyte).to_i
            else
              DEFAULT_MAX_BYTES
            end
    bytes.clamp(MIN_MAX_BYTES, MAX_MAX_BYTES)
  end

  def packager
    @packager ||= ::Sources::DocumentsPackager::Packager.new(
      query_params: @query_params,
      project_id: sessions_current_project_id
    )
  end

  def build_zip_filename(nickname, index, total)
    safe_nickname = nickname.presence || 'download'
    date = Time.zone.today.strftime('%-m_%-d_%y')
    Zaru::sanitize!("TaxonWorks-#{safe_nickname}-#{date}-#{index}_of_#{total}.zip").gsub(' ', '_')
  end

  def streamer
    @streamer ||= ::Sources::DocumentsPackager::Streamer.new
  end
end
