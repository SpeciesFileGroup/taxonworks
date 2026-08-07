export function makeGlobalId({ id, type, namespace = 'taxon-works' }) {
  return `gid://${namespace}/${type}/${id}`
}
