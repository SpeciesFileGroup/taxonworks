# Authored with assistance from Claude (Anthropic)
class Tasks::Images::ImagesPackagerController < ApplicationController
  include TaskControllerConfiguration
  include Tasks::PackagerController

  before_action :set_query_params, only: [:preview, :download]

  # GET /tasks/images/images_packager
  def index
  end

  # POST /tasks/images/images_packager/preview.json
  def preview
    preview_packager(
      packager: packager,
      payload_key: :images
    )
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

  def set_query_params
    raw = params[:image_id]
    ids = raw.is_a?(ActionController::Parameters) ? raw.values : Array.wrap(raw).compact
    @query_params = ids.any? ? { image_id: ids }.with_indifferent_access : {}
  end

  def packager
    @packager ||= Export::Packagers::Images.new(
      query_params: @query_params,
      project_id: sessions_current_project_id
    )
  end
end
