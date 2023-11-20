<template>
  <h1>Biological associations graph</h1>
  <div class="panel content margin-medium-bottom">
    <div class="flex-separate middle">
      <div class="horizontal-left-content middle">
        <div class="square-brackets margin-medium-left">
          <ul class="no_bullets context-menu">
            <li>
              <a
                :href="`/tasks/biological_associations/graph/data?${qs.stringify(
                  parameters,
                  { arrayFormat: 'brackets' }
                )}`"
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
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { downloadTextFile } from '@/helpers/files'
import { URLParamsToJSON } from '@/helpers/url/parse'
import { BiologicalAssociation } from '@/routes/endpoints'
import VSpinner from '@/components/spinner.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VGraph from '@/components/ui/VGraph/VGraph.vue'
import qs from 'qs'

const stats = ref({})
const graph = ref(null)
const currentNode = ref(null)
const isLoading = ref(false)
const showLabels = ref(true)
const nodes = ref([])
const edges = ref([])
const parameters = ref({})

function loadGraph(urlParameters) {
  BiologicalAssociation.graph(urlParameters).then(({ body }) => {
    stats.value = body.stats
    nodes.value = body.nodes.map((node) => ({ ...node, x: null, y: null }))
    edges.value = body.edges.map((link) => ({
      source: body.nodes.findIndex((node) => node.id === link.start_id),
      target: body.nodes.findIndex((node) => node.id === link.end_id)
    }))

    isLoading.value = false
  })
}

onMounted(() => {
  const urlParameters = {
    ...URLParamsToJSON(location.href),
    ...JSON.parse(sessionStorage.getItem('linkerQuery'))
  }

  parameters.value = urlParameters

  if (Object.keys(urlParameters).length) {
    loadGraph(urlParameters)
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
}
</style>
