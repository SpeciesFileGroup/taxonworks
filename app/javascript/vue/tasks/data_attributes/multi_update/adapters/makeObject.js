export function makeObject(data) {
  return {
    id: data.id,
    label: data.object_tag,
    plainLabel: data.object_label,
    type: data.base_class,
    dataAttributes: [],
    isUnsaved: false
  }
}
