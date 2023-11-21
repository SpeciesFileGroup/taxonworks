<template>
  <svg
    xmlns="http://www.w3.org/2000/svg"
    ref="svgElement"
    :class="!labels && 'hide-labels'"
  />
</template>

<script setup>
import * as d3 from 'd3'
import * as shapes from './svg'
import { ref, onMounted, watch } from 'vue'

const DEFAULT_LABEL_COLOR = '#000000'
const DEFAULT_STROKE_COLOR = '#ccc'

const size = 5

const opt = {
  size: 10
}

const props = defineProps({
  nodes: {
    type: Array,
    default: () => []
  },

  edges: {
    type: Array,
    default: () => []
  },

  labels: {
    type: Boolean,
    default: false
  },

  labelEdge: {
    type: Boolean,
    default: false
  },

  labelParallel: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['node:dbclick'])

let width = 0
let height = 0

const svgElement = ref(null)

let simulation

watch([() => props.edges, () => props.nodes], () => {
  initGraph({
    nodes: props.nodes.map((item) => ({ ...item })),
    edges: props.edges.map((item) => ({ ...item }))
  })
})

function translateLabel(d) {
  const dx = d.target.x - d.source.x
  const dy = d.target.y - d.source.y
  const angle = Math.atan2(dy, dx) * (180 / Math.PI)

  return (
    'translate(' +
    [(d.source.x + d.target.x) / 2, (d.source.y + d.target.y) / 2] +
    ') rotate(' +
    angle +
    ')'
  )
}

function initGraph({ nodes, edges }) {
  const graph = d3.select(svgElement.value)
  graph.selectAll('g').remove()
  const graphContainer = graph.append('g').attr('id', 'container')
  const zoom = d3.zoom().on('zoom', function (e) {
    graphContainer.attr('transform', e.transform)
  })

  graph.call(zoom).call(zoom.transform, d3.zoomIdentity)

  simulation = d3
    .forceSimulation(nodes)
    .force('charge', d3.forceManyBody().strength(-10).distanceMax(10))
    .force('center', d3.forceCenter(width / 2, height / 2))
    .force('link', d3.forceLink().links(edges).distance(150))
    .on('tick', ticked)

  function createLinks() {
    graphContainer.append('g').attr('class', 'links')

    const links = graphContainer
      .select('.links')
      .selectAll('line')
      .data(edges)
      .enter()
      .append('line')
      .attr('stroke', (d) => d.stroke || DEFAULT_STROKE_COLOR)

    return links
  }

  function createLabels() {
    graphContainer.append('g').attr('class', 'labels')

    const labels = graphContainer
      .selectAll('text')
      .data(edges)
      .enter()
      .append('text')
      .text((d) => d.label || '')
      .attr('font-size', 12)
      .attr('fill', (d) => d.color || DEFAULT_LABEL_COLOR)
      .attr('text-anchor', 'middle')
      .attr('dy', -2)
      .attr('transform', translateLabel)

    return labels
  }

  function createNodes() {
    graphContainer.append('g').attr('class', 'nodes')

    const nodeGroup = graphContainer
      .select('.nodes')
      .selectAll('.node')
      .data(nodes)
      .enter()
      .append('g')
      .attr('class', 'node')
      .call(drag(simulation))

    nodeGroup.append(function (d) {
      return this.appendChild(shapes[d.shape || 'circle'](d, opt))
    })

    nodeGroup
      .append('text')
      .text((d) => d.name)
      .attr('dx', size * 2 + 4)
      .attr('dy', size / 2)

    nodeGroup.on('dblclick', (e, d) => {
      e.stopPropagation()
      emit('node:dbclick', d)
    })

    return nodeGroup
  }

  let labels
  const links = createLinks()

  if (props.labelEdge) {
    labels = createLabels()
  }

  const nodeGroup = createNodes()

  function updateNodes() {
    nodeGroup.attr('transform', (d) => `translate(${d.x}, ${d.y})`)
  }

  function drag(simulation) {
    function dragstarted(event) {
      if (!event.active) simulation.alphaTarget(0.3).restart()
      event.subject.fx = event.subject.x
      event.subject.fy = event.subject.y
    }

    function dragged(event) {
      event.subject.fx = event.x
      event.subject.fy = event.y
    }

    function dragended(event) {
      if (!event.active) simulation.alphaTarget(0)
      event.subject.fx = null
      event.subject.fy = null
    }

    return d3
      .drag()
      .on('start', dragstarted)
      .on('drag', dragged)
      .on('end', dragended)
  }

  function updateLinks() {
    links
      .attr('x1', (d) => d.source.x)
      .attr('y1', (d) => d.source.y)
      .attr('x2', (d) => d.target.x)
      .attr('y2', (d) => d.target.y)
  }

  function updateLabels() {
    if (props.labelParallel) {
      labels.attr('transform', translateLabel)
    } else {
      labels
        .attr('x', (d) => (d.source.x + d.target.x) / 2)
        .attr('y', (d) => (d.source.y + d.target.y) / 2)
    }
  }

  function ticked() {
    updateLinks()
    updateNodes()

    if (props.labelEdge) {
      updateLabels()
    }
  }
}

function getSVGElement() {
  return svgElement.value
}

onMounted(() => {
  height = svgElement.value.clientHeight
  width = svgElement.value.clientWidth

  initGraph({
    nodes: props.nodes.map((item) => ({ ...item })),
    edges: props.edges.map((item) => ({ ...item }))
  })
})

defineExpose({
  getSVGElement
})
</script>
<style lang="scss" scoped>
:deep(.node) {
  cursor: pointer;
}

.hide-labels {
  :deep(text) {
    display: none;
  }
}
</style>
