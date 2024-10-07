export function makeContainerPayload(data) {
  return {
    id: data.id,
    name: data.name,
    type: data.type,
    size_x: data.size.x,
    size_y: data.size.y,
    size_z: data.size.z
  }
}
