# Authored with assistance from Claude (Anthropic)
class Tasks::Images::ImagesPackagerController < ApplicationController
  include TaskControllerConfiguration
  include Tasks::PackagerController
  include ZipTricks::RailsStreaming

  before_action -> { set_query_params_for(:image_query) }, only: [:preview, :download]

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
    download_packager(
      packager: packager,
      group_index: params[:group].to_i,
      empty_message: 'No images queued.',
      filename_prefix: 'TaxonWorks-images_download'
    )
  end

  private

  def packager
    @packager ||= Export::Packagers::Images.new(
      query_params: @query_params,
      project_id: sessions_current_project_id
    )
  end
end
