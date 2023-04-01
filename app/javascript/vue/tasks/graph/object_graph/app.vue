<template>
  <h1>Task: Object graph</h1>
  <div class="panel content margin-medium-bottom">
    <div class="horizontal-left-content middle">
      <h3 v-if="currentNode">Target: {{ currentNode.name }}</h3>
      <h3 v-else>Target: None</h3>
      <div
        v-if="currentNode"
        class="square-brackets margin-medium-left"
      >
        <ul class="no_bullets context-menu">
          <li>
            <a
              :href="`/graph/${encodeURIComponent(currentGlobalId)}/object`"
              target="_blank"
            >
              JSON
            </a>
          </li>
          <li>
            <v-btn
              color="primary"
              circle
              @click="
                () =>
                  downloadTextFile(
                    svgElement.outerHTML,
                    'image/svg+xml',
                    'graph.svg'
                  )
              "
            >
              <v-icon
                color="white"
                x-small
                name="download"
              />
            </v-btn>
          </li>
          <li>
            <radial-annotator :global-id="currentNode.id" />
          </li>
          <li>
            <radial-navigation :global-id="currentNode.id" />
          </li>
        </ul>
      </div>
    </div>
  </div>
  <div class="graph-container panel">
    <VSpinner
      v-if="isLoading"
      full-screen
    />
    <div class="panel content graph-container__stats">
      <ul class="capitalize">
        <li
          v-for="(value, key) in stats"
          :key="key"
        >
          {{ key }}: {{ value }}
        </li>
      </ul>
    </div>
    <svg
      xmlns="http://www.w3.org/2000/svg"
      ref="svgElement"
    ></svg>
  </div>
</template>

<script setup>
import * as d3 from 'd3'
import { ref, onMounted } from 'vue'
import SetParam from 'helpers/setParam'
import AjaxCall from 'helpers/ajaxCall'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialNavigation from 'components/radials/navigation/radial.vue'
import VSpinner from 'components/spinner.vue'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import { downloadTextFile } from 'helpers/files'
import * as shapes from './components/Svg'

const size = 5

const opt = {
  size: 10
}

let width = 0
let height = 0

const stats = ref({})
const svgElement = ref(null)
const currentNode = ref(null)
const isLoading = ref(false)
const currentGlobalId = ref(null)
let nodes = []
let links = []
let simulation

function initGraph() {
  const graph = d3.select(svgElement.value)
  graph.selectAll('g').remove()
  const graphContainer = graph.append('g').attr('id', 'container')
  const zoom = d3.zoom().on('zoom', function (e) {
    graphContainer.attr('transform', e.transform)
  })

  graph.call(zoom)

  simulation = d3
    .forceSimulation(nodes)
    .force('charge', d3.forceManyBody().strength(-100))
    .force('center', d3.forceCenter(width / 2, height / 2))
    .force('link', d3.forceLink().links(links))
    .on('tick', ticked)

  function createNodes() {
    graphContainer.append('g').attr('class', 'links')

    graphContainer
      .select('.links')
      .selectAll('line')
      .data(links)
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

    nodeGroup
      .on('click', (e, d) => {
        currentNode.value = d
      })
      .on('dblclick', (e, d) => {
        e.stopPropagation()
        loadGraph(d.id)
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

function loadGraph(globalId) {
  currentGlobalId.value = globalId
  isLoading.value = true

  SetParam('/tasks/graph/object', 'global_id', globalId)
  AjaxCall('get', `/graph/${encodeURIComponent(globalId)}/object`).then(
    ({ body }) => {
      stats.value = body.stats
      nodes = body.nodes.map((node) => ({ ...node, x: null, y: null }))
      links = body.edges.map((link) => ({
        source: body.nodes.findIndex((node) => node.id === link.start_id),
        target: body.nodes.findIndex((node) => node.id === link.end_id)
      }))

      initGraph()
      isLoading.value = false
    }
  )
}

onMounted(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const globalId = urlParams.get('global_id')

  height = svgElement.value.clientHeight
  width = svgElement.value.clientWidth

  if (globalId) {
    loadGraph(globalId)
  }
})
</script>
<style lang="scss">
.graph-container {
  svg {
    width: 100%;
    height: calc(100vh - 250px);
    cursor: move;
  }
  position: relative;

  &__stats {
    position: absolute;
  }

  ul {
    padding-left: 1em;
    margin: 0;
  }

  .node {
    cursor: pointer;
  }
}
</style>
