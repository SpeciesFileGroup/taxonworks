export function makeContainerItem(cItem) {
  return {
    id: cItem.id,
    label: cItem.contained_object?.object_label,
    objectId: cItem.contained_object_id,
    objectType: cItem.contained_object_type,
    position: {
      x: cItem.disposition_x || null,
      y: cItem.disposition_y || null,
      z: cItem.disposition_z || null
    }
  }
}
