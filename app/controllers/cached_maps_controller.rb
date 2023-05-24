class CachedMapsController < ApplicationController
  include DataControllerConfiguration::ProjectDataControllerConfiguration

  def show 
    @cached_map = CachedMap.select(:id, :otu_id, :reference_count, :cached_map_type, :updated_at, :created_at)
      .where(project_id: sessions_current_project_id).find(params[:id])
  end 

  protected

  def set_cached_map
    CachedMap.where(project_id: sessions_current_project_id).find(params[:id])
  end

end
