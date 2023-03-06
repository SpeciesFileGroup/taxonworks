<template>
  <div>
    <h1>Biological associations graph</h1>
    <BiologicalAssociationGraph ref="graph">
      <template #header="{ isGraphUnsaved, edges, currentGraph }">
        <VNavbar>
          <div class="flex-separate">
            <div class="horizontal-left-content middle gap-small">
              <VAutocomplete
                url="/biological_associations_graphs/autocomplete"
                param="term"
                label="label_html"
                clear-after
                placeholder="Search a graph..."
                @get-item="
                  ({ id }) => {
                    graph.resetStore()
                    graph.setGraph(id)
                  }
                "
              />
              <span v-if="currentGraph.id">{{ currentGraph.object_tag }}</span>
            </div>
            <div class="horizontal-left-content gap-small">
              <VIcon
                v-if="isGraphUnsaved"
                name="attention"
                small
                color="attention"
                title="You have unsaved changes."
              />
              <VBtn
                color="create"
                medium
                :disabled="!Object.keys(edges).length"
                @click="saveGraph"
              >
                Save
              </VBtn>
              <VBtn
                color="primary"
                circle
                medium
                @click="reset"
              >
                <VIcon
                  name="reset"
                  x-small
                />
              </VBtn>
            </div>
          </div>
        </VNavbar>
      </template>
    </BiologicalAssociationGraph>
  </div>
</template>

<script setup>
import BiologicalAssociationGraph from './components/BiologicalAssociationGraph.vue'
import VNavbar from 'components/layout/NavBar'
import VBtn from 'components/ui/VBtn/index.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import VAutocomplete from 'components/ui/Autocomplete.vue'
import { URLParamsToJSON } from 'helpers/url/parse'
import { onMounted, ref } from 'vue'
import { CollectionObject, Otu } from 'routes/endpoints'
import { RouteNames } from 'routes/routes.js'
import setParam from 'helpers/setParam.js'

const graph = ref()

onMounted(() => {
  const params = URLParamsToJSON(location.href)
  const biologicalAssociationGraphId = params.biological_associations_graph_id
  const coId = params.collection_object_id
  const otuId = params.otu_id

  if (biologicalAssociationGraphId) {
    loadGraph(biologicalAssociationGraphId)
  }

  if (coId) {
    CollectionObject.find(coId).then(({ body }) => {
      graph.value.addObject(body)
    })
  }

  if (otuId) {
    Otu.find(otuId).then(({ body }) => {
      graph.value.addObject(body)
    })
  }
})

function loadGraph(id) {
  graph.value.setGraph(id)
}

function saveGraph() {
  graph.value.saveBiologicalAssociations()
}

function reset() {
  graph.value.resetStore()
  setParam(
    RouteNames.NewBiologicalAssociationGraph,
    'biological_associations_graph_id'
  )
}
</script>

<style scoped>
.graph-section {
  position: relative;
}
</style>
