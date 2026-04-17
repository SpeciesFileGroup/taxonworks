class Tasks::Containers::CollectionLayoutController < ApplicationController
  include TaskControllerConfiguration

  # GET /tasks/containers/collection_layout
  def index
  end

  # GET /tasks/containers/collection_layout/children.json?container_id=123
  # Returns the direct children of a container with their placement (disposition_x/y/z)
  # and whether each child itself has children (for drill-down eligibility).
  def children
    id        = params[:container_id] || params[:building_id]
    container = Container.with_project_id(sessions_current_project_id).find(id)
    ci        = ContainerItem.find_by(contained_object: container)

    items = ci ? ci.children.map { |child_ci|
      obj = child_ci.contained_object
      {
        container_item_id: child_ci.id,
        id:                obj.id,
        name:              obj.name.presence || obj.type.demodulize,
        type:              obj.type,
        disposition_x:     child_ci.disposition_x,
        disposition_y:     child_ci.disposition_y,
        disposition_z:     child_ci.disposition_z,
        has_children:      child_ci.children.exists?
      }
    } : []

    render json: items
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Container not found' }, status: :not_found
  end

  # GET /tasks/containers/collection_layout/collection_tree.json?building_id=123
  # Returns hierarchical treemap data for a given building Container id
  def collection_tree
    building_id = params.require(:building_id)
    building = Container.with_project_id(sessions_current_project_id).find(building_id)
    render json: CollectionLayout::TreeData.new(building).to_json_tree
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Building not found' }, status: :not_found
  end

  # POST /tasks/containers/collection_layout/scaffold.json
  # Params: building_id, cabinet_type, rooms, cabinets, drawers
  def scaffold
    building = Container.with_project_id(sessions_current_project_id).find(params.require(:building_id))
    result = Container.scaffold(scaffold_params.merge(building_id: building.id))

    if result
      render json: { created_rooms: result.length }, status: :created
    else
      render json: { error: 'Failed to scaffold containers. Check params.' }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Building not found' }, status: :not_found
  end

  private

  def scaffold_params
    params.permit(:building_id, :cabinet_type, :rooms, :cabinets, :drawers,
                  :cabinet_size_x, :cabinet_size_y, :cabinet_size_z,
                  :asserted_percent_empty, :asserted_percent_earmarked)
  end

end
