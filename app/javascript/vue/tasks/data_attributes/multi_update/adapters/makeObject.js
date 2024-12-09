export function makeObject(data) {
  return {
    id: data.id,
    objectType: data.base_class,
    predicates: [],
    isUnsaved: false
  }
}
