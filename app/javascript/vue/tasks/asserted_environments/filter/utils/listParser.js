export function listParser(list) {
  return list.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    uri_label: item.uri_label,
    uri: item.uri,
    object_type: item.asserted_environment_object_type,
    objectGlobalId: item.asserted_environment_object.global_id,
    object_object_tag: item.asserted_environment_object.object_tag
  }))
}
