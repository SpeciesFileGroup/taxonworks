export function listParser(list) {
  return list.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    name: item.name,
    uri: item.uri,
    uri_label: item.uri_label,
    is_material: item.is_material,
    graph: item.id
  }))
}
