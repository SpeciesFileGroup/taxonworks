<template>
  <h1>Task: Object graph</h1>
  <div class="panel content margin-medium-bottom">
    <div class="flex-separate middle">
      <div class="horizontal-left-content middle">
        <h3>
          <span>Target: <span v-html="currentNode?.name" /></span>
        </h3>
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
                      graph.getSVGElement().outerHTML,
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
      <div>
        <label>
          <input
            type="checkbox"
            v-model="showLabels"
          />
          Show labels
        </label>
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
    <VGraph
      ref="graph"
      :edges="edges"
      :nodes="nodes"
      :labels="showLabels"
      @node:dbclick="(e) => loadGraph(e.id)"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import SetParam from '@/helpers/setParam'
import AjaxCall from '@/helpers/ajaxCall'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigation from '@/components/radials/navigation/radial.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VGraph from '@/components/ui/VGraph/VGraph.vue'
import { downloadTextFile } from '@/helpers/files'

const stats = ref({})
const graph = ref(null)
const currentNode = ref(null)
const isLoading = ref(false)
const currentGlobalId = ref(null)
const showLabels = ref(true)
const nodes = ref([])
const edges = ref([])

function loadGraph(globalId) {
  currentGlobalId.value = globalId
  isLoading.value = true

  SetParam('/tasks/graph/object', 'global_id', globalId)
  AjaxCall('get', `/graph/${encodeURIComponent(globalId)}/object`).then(
    ({ body }) => {
      stats.value = body.stats
      nodes.value = body.nodes.map((node) => ({ ...node, x: null, y: null }))
      edges.value = body.edges.map((link) => ({
        source: body.nodes.findIndex((node) => node.id === link.start_id),
        target: body.nodes.findIndex((node) => node.id === link.end_id)
      }))

      currentNode.value = nodes.value.find((n) => n.id === globalId)

      isLoading.value = false
    }
  )
}

onMounted(() => {
  const urlParams = new URLSearchParams(window.location.search)
  const globalId = urlParams.get('global_id')

  if (globalId) {
    loadGraph(globalId)
  }
})
</script>
<style lang="scss">
.graph-container {
  position: relative;

  svg {
    width: 100%;
    height: calc(100vh - 250px);
    cursor: move;
  }

  &__stats {
    position: absolute;
  }

  ul {
    padding-left: 1em;
    margin: 0;
  }
}
</style>
