export function parseNodeId(nodeId) {
  const [objectType, id] = nodeId.split(':')

  return {
    id: Number(id),
    objectType
  }
}
