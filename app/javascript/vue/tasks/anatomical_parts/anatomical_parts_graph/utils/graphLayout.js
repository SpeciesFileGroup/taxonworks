import * as dagre from '@dagrejs/dagre'

export function graphLayout({ nodes, edges, nodeSize }) {
  if (Object.keys(nodes).length <= 1 || Object.keys(edges).length === 0) {
    return
  }

  const direction = 'TB'
  const g = new dagre.graphlib.Graph()

  g.setGraph({
    rankdir: direction,
    nodesep: 300,
    ranksep: 200,
    edgesep: 10
  })

  g.setDefaultEdgeLabel(() => ({}))

  Object.entries(nodes).forEach(([nodeId, node]) => {
    g.setNode(nodeId, { label: node.name, width: nodeSize, height: nodeSize })
  })

  Object.values(edges).forEach((edge) => {
    g.setEdge(edge.source, edge.target)
  })

  dagre.layout(g)

  const box = {}
  const layouts = { nodes: {} }
  g.nodes().forEach((nodeId) => {
    const x = g.node(nodeId).x
    const y = g.node(nodeId).y
    layouts.nodes[nodeId] = { x, y }

    box.top = box.top ? Math.min(box.top, y) : y
    box.bottom = box.bottom ? Math.max(box.bottom, y) : y
    box.left = box.left ? Math.min(box.left, x) : x
    box.right = box.right ? Math.max(box.right, x) : x
  })

  const graphMargin = nodeSize * 2
  const viewBox = {
    top: (box.top ?? 0) - graphMargin,
    bottom: (box.bottom ?? 0) + graphMargin,
    left: (box.left ?? 0) - graphMargin,
    right: (box.right ?? 0) + graphMargin
  }

  return {
    viewBox,
    layouts
  }
}
