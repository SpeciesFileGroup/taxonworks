# Authored with assistance from Claude (Anthropic)
class Tasks::Images::ImagesPackagerController < ApplicationController
  include TaskControllerConfiguration
  include ZipTricks::RailsStreaming

  DEFAULT_MAX_MB = 50
  MIN_MAX_MB = 10
  MAX_MAX_MB = 1000

  before_action :set_query_params, only: [:preview, :download]

  # GET /tasks/images/images_packager
  def index
  end

  # POST /tasks/images/images_packager/preview.json
  def preview
    max_bytes = requested_max_bytes
    preview_data = packager.preview(max_bytes: max_bytes)

    render json: {
      images: preview_data[:images],
      groups: preview_data[:groups],
      filter_params: @query_params,
      total_images: preview_data[:total_images],
      max_bytes: max_bytes
    }
  end

  # POST /tasks/images/images_packager/download
  def download
    query_params = @query_params
    group_index = params[:group].to_i

    render json: { error: 'No images queued.' }, status: :unprocessable_content and return if query_params.blank?

    max_bytes = requested_max_bytes
    groups = packager.groups(max_bytes: max_bytes)
    group = groups[group_index - 1]

    render json: { error: 'Group not found.' }, status: :not_found and return if group.blank?

    entries = group.select { |image| packager.file_available?(image) }

    render json: { error: 'No files available for this package.' }, status: :unprocessable_content and return if entries.empty?

    filename = build_zip_filename(group_index, groups.length)
    response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
    packager.stream(entries: entries, zip_streamer: method(:zip_tricks_stream))
  end

  private

  def set_query_params
    @query_params = params[:image_query].presence || params
    @query_params = @query_params.to_unsafe_h if @query_params.respond_to?(:to_unsafe_h)
    @query_params = @query_params.except(
      'controller',
      'action',
      'format',
      'group',
      'max_mb',
      'authenticity_token',
      'token'
    )
  end

  def requested_max_bytes
    mb = params[:max_mb].presence
    mb = mb.to_f if mb
    mb = if mb && mb.positive?
           mb
         else
           DEFAULT_MAX_MB
         end
    mb = mb.clamp(MIN_MAX_MB, MAX_MAX_MB)
    (mb * 1_000_000).to_i
  end

  def packager
    @packager ||= Export::Packagers::Images.new(
      query_params: @query_params,
      project_id: sessions_current_project_id
    )
  end

  def build_zip_filename(index, total)
    date = Time.zone.today.strftime('%-m_%-d_%y')
    Zaru.sanitize!("TaxonWorks-images_download-#{date}-#{index}_of_#{total}.zip").gsub(' ', '_')
  end
end
