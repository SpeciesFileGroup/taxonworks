<template>
  <div>
    <h1>Biological associations graph</h1>
    <VNavbar>
      <div class="flex-separate">
        <VAutocomplete
          url="/biological_associations_graphs/autocomplete"
          param="term"
          label="label_html"
          clear-after
          placeholder="Search a graph..."
          @get-item="({ id }) => loadGraph(id)"
        />
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
            @click="() => saveBiologicalAssociations()"
          >
            Save
          </VBtn>
          <VBtn
            color="primary"
            circle
            medium
            @click="resetStore"
          >
            <VIcon
              name="reset"
              x-small
            />
          </VBtn>
        </div>
      </div>
    </VNavbar>
    <BiologicalAssociationGraph ref="graph" />
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
import { useGraph } from './composition/useGraph.js'

const graph = ref()
const { saveBiologicalAssociations, isGraphUnsaved, edges, resetStore } =
  useGraph()

onMounted(() => {
  const params = URLParamsToJSON(location.href)
  const biologicalAssociationGraphId = params.biological_assocciations_graph_id
  const coId = params.collection_object_id
  const otuId = params.otu_id

  if (biologicalAssociationGraphId) {
    loadGraph(biologicalAssociationGraphId)
  }

  if (coId) {
    loadCO(coId)
  }

  if (otuId) {
    loadOtu(otuId)
  }
})

function loadGraph(id) {
  graph.value.setGraph(id)
}
</script>

<style scoped>
.graph-section {
  position: relative;
}
</style>
