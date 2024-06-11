import { randomUUID } from '@/helpers'

export function makeContainerItem(data) {
  return {
    id: data?.id,
    uuid: randomUUID(),
    label: data?.contained_object?.object_label,
    objectId: data?.contained_object_id,
    objectType: data?.contained_object_type,
    disposition: data?.disposition,
    position: {
      x: data?.disposition_x ?? null,
      y: data?.disposition_y ?? null,
      z: data?.disposition_z ?? null
    },
    isUnsaved: false
  }
}
