<template>
  <h1> Task: Object graph</h1>
  <h3>Target: {{ currentNodeName }}</h3>
  <svg
    v-if="bounds.minX"
    xmlns="http://www.w3.org/2000/svg"
    :width="width+'px'"
    :height="height+'px'"
    @mousemove="drag($event)"
    @mouseup="drop()"
  >
    <line
      v-for="link in graph.links"
      :x1="coords[link.source.index].x"
      :y1="coords[link.source.index].y"
      :x2="coords[link.target.index].x"
      :y2="coords[link.target.index].y"
      stroke="black"
      stroke-width="2"
    />
    <g
      v-for="node in graph.nodes"
      :key="node.id">
      <circle
        :cx="coords[node.index].x"
        :cy="coords[node.index].y"
        :r="radio"
        stroke="white"
        stroke-width="1"
        :title="node.name"
        :fill="node.color"
        @dblclick="loadGraph(node.id)"
        @mousedown="currentMove = { x: $event.screenX, y: $event.screenY, node: node }"
        @mouseup="drop()"
      />
      <text
        :x="coords[node.index].x + radio"
        :y="coords[node.index].y"
        dy=".3em"
      >
        {{ node.name }}
      </text>
      <title>{{ node.name }}</title>
    </g>
  </svg>
</template>

<script setup>
import * as d3 from 'd3'
import { ref, computed } from 'vue'
import SetParam from 'helpers/setParam'
import AjaxCall from 'helpers/ajaxCall'

const graph = ref({
  nodes: [],
  links: []
})

const radio = 10
const width = Math.max(document.documentElement.clientWidth, window.innerWidth || 0) - 20
const height = Math.max(document.documentElement.clientHeight, window.innerHeight || 0) - 200
const simulation = ref(null)
const currentMove = ref(null)
const currentGlobalId = ref()

const bounds = computed(() => ({
  minX: Math.min(...graph.value.nodes.map(n => n.x)),
  maxX: Math.max(...graph.value.nodes.map(n => n.x)),
  minY: Math.min(...graph.value.nodes.map(n => n.y)),
  maxY: Math.max(...graph.value.nodes.map(n => n.y))
}))

const coords = computed(() => graph.value.nodes.map(node => ({
  x: node.x,
  y: node.y
})))

const currentNodeName = computed(() => graph.value.nodes.find(node => node.id === currentGlobalId.value)?.name)

const drag = e => {
  if (currentMove.value) {
    currentMove.value.node.fx = currentMove.value.node.x - (currentMove.value.x - e.screenX)
    currentMove.value.node.fy = currentMove.value.node.y - (currentMove.value.y - e.screenY)
    currentMove.value.x = e.screenX
    currentMove.value.y = e.screenY
  }
}
const drop = () => {
  if (!currentMove.value) return
  delete currentMove.value.node.fx
  delete currentMove.value.node.fy
  currentMove.value = null
  simulation.value.alpha(1)
  simulation.value.restart()
}

const loadGraph = globalId => {
  currentGlobalId.value = globalId
  SetParam('/tasks/collection_objects/object_graph', 'global_id', globalId)
  AjaxCall('get', `/graph/${encodeURIComponent(globalId)}/object`).then(({ body }) => {
    graph.value = {
      nodes: body.nodes.map(node => ({ ...node, x: null, y: null })),
      links: body.edges.map(link => ({
        source: body.nodes.findIndex(node => node.id === link.start_id),
        target: body.nodes.findIndex(node => node.id === link.end_id)
      }))
    }

    simulation.value = d3.forceSimulation(graph.value.nodes)
      .force('charge', d3.forceManyBody().strength(d => -40))
      .force('link', d3.forceLink(graph.value.links))
      .force('center', d3.forceCenter(width / 2, height / 2))
  })
}

const urlParams = new URLSearchParams(window.location.search)
const globalId = urlParams.get('global_id')

if (globalId) {
  loadGraph(globalId)
}

</script>
