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
import { ref, onMounted, watch, toRaw } from 'vue'

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
  }
})

const emit = defineEmits(['node:dbclick'])

let width = 0
let height = 0
/* let nodes = []
let edges = [] */

const svgElement = ref(null)

let simulation

watch([() => props.edges, () => props.nodes], () => {
  initGraph({
    nodes: props.nodes.map((item) => ({ ...item })),
    edges: props.edges.map((item) => ({ ...item }))
  })
})

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

  function createNodes() {
    graphContainer.append('g').attr('class', 'links')

    graphContainer
      .select('.links')
      .selectAll('line')
      .data(edges)
      .enter()
      .append('line')
      .attr('stroke', '#ccc')

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
      .text(function (d) {
        return d.name
      })
      .attr('dx', size * 2 + 4)
      .attr('dy', size / 2)

    nodeGroup.on('dblclick', (e, d) => {
      e.stopPropagation()
      emit('node:dbclick', d)
    })
  }

  createNodes()

  function updateNodes() {
    graphContainer.selectAll('.node').attr('transform', function (d) {
      return `translate(${d.x}, ${d.y})`
    })
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
    graphContainer
      .selectAll('line')
      .attr('x1', (d) => d.source.x)
      .attr('y1', (d) => d.source.y)
      .attr('x2', (d) => d.target.x)
      .attr('y2', (d) => d.target.y)
  }

  function ticked() {
    updateNodes()
    updateLinks()
  }
}

function getSVGElement() {
  return svgElement.value
}

onMounted(() => {
  height = svgElement.value.clientHeight
  width = svgElement.value.clientWidth

  initGraph({
    nodes: toRaw(props.nodes),
    edges: toRaw(props.edges)
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
