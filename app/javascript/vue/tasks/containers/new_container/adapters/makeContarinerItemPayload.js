export function makeContainerItemPayload(data) {
  return {
    id: data?.id,
    object_id: data?.objectId,
    object_type: data?.objectType,
    disposition_x: data.position.x,
    disposition_y: data.position.y,
    disposition_z: data.position.z
  }
}
