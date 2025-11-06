export function removeNode(nodes, { id, parentId }) {
  if (!Array.isArray(nodes)) return

  for (let i = nodes.length - 1; i >= 0; i--) {
    const node = nodes[i]

    if (node.id === id && node.parentId === parentId) {
      nodes.splice(i, 1)

      continue
    }

    if (node.children && node.children.length > 0) {
      removeNode(node.children, { id, parentId: node.id })
    }
  }
}
