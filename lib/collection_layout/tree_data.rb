# Aggregates container hierarchy data for a Building container into a
# nested hash suitable for Apache ECharts treemap rendering.
#
# Usage:
#   CollectionLayout::TreeData.new(building_container).to_json_tree
#
module CollectionLayout
  class TreeData

    # @param building [Container::Building]
    def initialize(building)
      @building = building
    end

    # @return [Hash] nested treemap-compatible structure
    def to_json_tree
      ci = ContainerItem.find_by(contained_object: @building)
      return building_node(@building, []) if ci.nil?

      room_nodes = ci.children.map do |ci_room|
        room = ci_room.contained_object
        cabinet_nodes = ci_room.children.map do |ci_cabinet|
          cabinet = ci_cabinet.contained_object

          drawer_nodes = ci_cabinet.children.map do |ci_drawer|
            drawer = ci_drawer.contained_object
            leaf_node(drawer)
          end

          container_node(cabinet, drawer_nodes)
        end
        container_node(room, cabinet_nodes)
      end

      building_node(@building, room_nodes)
    end

    private

    def building_node(container, children)
      {
        id: container.id,
        name: container.name.presence || "Building #{container.id}",
        type: container.type,
        children: children
      }
    end

    def container_node(container, children)
      {
        id: container.id,
        name: container.name.presence || container.type.demodulize,
        type: container.type,
        children: children
      }
    end

    def leaf_node(container)
      {
        id: container.id,
        name: container.name.presence || container.type.demodulize,
        type: container.type,
        value: 1,
        children: []
      }
    end

  end
end
