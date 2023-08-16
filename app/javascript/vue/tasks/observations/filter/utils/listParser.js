export function listParser(list) {
  return list.map((item) => ({
    ...item,
    observation_object: item.observation_object.object_tag
  }))
}
