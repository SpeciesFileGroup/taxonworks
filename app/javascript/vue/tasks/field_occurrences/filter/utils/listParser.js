export function listParser(list) {
  return list.map((item) => ({
    id: item.id,
    global_id: item.global_id,
    label: item.object_tag,
    isAbsent: item.isAbsent ? 'Yes' : 'No',
    total: item.total
  }))
}
