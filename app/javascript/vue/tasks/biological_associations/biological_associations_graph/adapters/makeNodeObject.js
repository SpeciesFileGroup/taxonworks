export function makeNodeObject(obj) {
  return {
    id: obj.id,
    objectType: obj.base_class,
    name: obj.object_label
  }
}
