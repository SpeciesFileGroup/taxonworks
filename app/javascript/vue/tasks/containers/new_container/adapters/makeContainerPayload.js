export function makeContainerPayload(data) {
  return {
    id: data.id,
    name: data.name,
    type: data.type,
    parent_id: data.parentId,
    size_x: data.size.x,
    size_y: data.size.y,
    size_z: data.size.z
  }
}
