class Tasks::Containers::CollectionVisualizationController < ApplicationController
  include TaskControllerConfiguration

  def index
  end

  # GET /tasks/containers/collection_visualization/collection_tree.json?building_id=123
  def collection_tree
    building_id = params.require(:building_id)
    building    = Container.with_project_id(sessions_current_project_id).find(building_id)
    render json: CollectionLayout::TreeData.new(building).to_json_tree
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Building not found' }, status: :not_found
  end

end
