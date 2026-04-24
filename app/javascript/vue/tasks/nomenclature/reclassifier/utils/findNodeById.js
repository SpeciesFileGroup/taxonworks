export function findNodeById(treeArray, id) {
  for (const node of treeArray) {
    if (node.id == id) return node
    if (node.children && node.children.length) {
      const found = findNodeById(node.children, id)
      if (found) return found
    }
  }

  return null
}
