import { makeTaxonNodeWithState } from './makeTaxonNameNodeWithStats'

export function buildTree(data) {
  const nodesById = new Map()

  data.forEach((item) => {
    nodesById.set(item.id, makeTaxonNodeWithState(item))
  })

  const roots = []

  data.forEach((item) => {
    const node = nodesById.get(item.id)

    if (item.parent_id === null) {
      roots.push(node)
    } else {
      const parent = nodesById.get(item.parent_id)
      if (parent) {
        parent.children.push(node)
      } else {
        roots.push(node)
      }
    }
  })

  return roots
}
