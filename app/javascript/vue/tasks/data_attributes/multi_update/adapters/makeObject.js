export function makeObject(data) {
  return {
    id: data.id,
    label: data.object_tag,
    type: data.base_class,
    dataAttributes: [],
    isUnsaved: false
  }
}
