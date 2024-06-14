export function makeContainer(container = {}) {
  return {
    id: container.id,
    globalId: container.global_id,
    name: container.name,
    type: container.type,
    size: {
      x: container.size_x || 0,
      y: container.size_y || 0,
      z: container.size_z || 0
    },
    objectTag: container.object_tag,
    parentId: null,
    isUnsaved: false
  }
}
