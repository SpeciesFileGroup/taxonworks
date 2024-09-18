export function makeContainerItemPayload(data) {
  return {
    id: data?.id,
    container_id: data.containerId,
    contained_object_id: data?.objectId,
    contained_object_type: data?.objectType,
    disposition: data.disposition,
    disposition_x: data.position.x,
    disposition_y: data.position.y,
    disposition_z: data.position.z
  }
}
