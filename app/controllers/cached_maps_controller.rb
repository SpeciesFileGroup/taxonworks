class CachedMapsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  before_action :set_cached_map, only: [:show, :update]

  def show
  end

  def update
    @cached_map.update!(force_rebuild: true)
  end

  private

  def set_cached_map
    @cached_map = CachedMap.select(
      :id, :otu_id,
      :reference_count, :cached_map_type,
      :updated_at, :created_at
      ).where(project_id: sessions_current_project_id).find(params[:id])
  end

end
