export function makeIdentifier (data) {
  return {
    id: data.id,
    baseClass: data.base_class,
    globalId: data.globalId,
    objectId: data.identifier_object_id,
    objectType: data.identifier_object_type,
    namespaceId: data.namespaceId,
    objectLabel: data.objectLabel,
    objectTag: data.object_tag,
    type: data.type,
    identifier: data.identifier
  }
}
