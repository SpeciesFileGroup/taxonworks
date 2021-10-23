<template>
  <h1>Welcome to your new Vue task!</h1>
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
    <circle v-for="(node, i) in graph.nodes"
      :cx="coords[i].x"
      :cy="coords[i].y"
      :r="20" :fill="colors[Math.ceil(Math.sqrt(node.index))]"
      stroke="white" stroke-width="1"
      @mousedown="currentMove = {x: $event.screenX, y: $event.screenY, node: node}"/>
  </svg>
</template>

<script setup>
import * as d3 from 'd3'
import { ref, computed } from 'vue'

const graph = ref({
  nodes: d3.range(100).map(i => ({ index: i, x: null, y: null })),
  links: d3.range(99).map(i => ({ source: Math.floor(Math.sqrt(i)), target: i + 1 }))
})
const width = Math.max(document.documentElement.clientWidth, window.innerWidth || 0)
const height = Math.max(document.documentElement.clientHeight, window.innerHeight || 0) - 40
const padding = 20
const colors = ['#2196F3', '#E91E63', '#7E57C2', '#009688', '#00BCD4', '#EF6C00', '#4CAF50', '#FF9800', '#F44336', '#CDDC39', '#9C27B0']
const simulation = ref(null)
const currentMove = ref(null)

const bounds = computed(() => ({
  minX: Math.min(...graph.value.nodes.map(n => n.x)),
  maxX: Math.max(...graph.value.nodes.map(n => n.x)),
  minY: Math.min(...graph.value.nodes.map(n => n.y)),
  maxY: Math.max(...graph.value.nodes.map(n => n.y))
}))

const coords = computed(() => graph.value.nodes.map(node => ({
  x: padding + (node.x - bounds.value.minX) * (width - 2*padding) / (bounds.value.maxX - bounds.value.minX),
  y: padding + (node.y - bounds.value.minY) * (height - 2*padding) / (bounds.value.maxY - bounds.value.minY)
})))

simulation.value = d3.forceSimulation(graph.value.nodes)
  .force('charge', d3.forceManyBody().strength(d => -100))
  .force('link', d3.forceLink(graph.value.links))
  .force('x', d3.forceX())
  .force('y', d3.forceY())

const drag = e => {
  if (currentMove.value) {
    currentMove.value.node.fx = currentMove.value.node.x - (currentMove.value.x - e.screenX) * (bounds.value.maxX - bounds.value.minX) / (width - 2 * padding)
    currentMove.value.node.fy = currentMove.value.node.y -(currentMove.value.y - e.screenY) * (bounds.value.maxY - bounds.value.minY) / (height - 2 * padding)
    currentMove.value.x = e.screenX
    currentMove.value.y = e.screenY
  }
}
const drop = () => {
  delete currentMove.value.node.fx
  delete currentMove.value.node.fy
  currentMove.value = null
  simulation.value.alpha(1)
  simulation.value.restart()
}
</script>