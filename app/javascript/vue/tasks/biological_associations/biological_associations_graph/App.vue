<template>
  <div>
    <h1>Biological associations graph</h1>
    <VNavbar />
    <section class="graph-section">
      <NetworkCanvas />
    </section>

    <ModalNode
      v-if="store.modal.node"
      @close="() => (store.modal.node = false)"
    />
    <ModalEdge
      v-if="store.modal.edge"
      @close="() => (store.modal.edge = false)"
    />
    <VSpinner
      v-if="store.settings.isSaving"
      full-screen
      legend="Saving biological associations..."
    />
  </div>
</template>

<script setup>
import NetworkCanvas from './components/NetworkCanvas.vue'
import VNavbar from './components/Navbar.vue'
import ModalNode from './components/ModalNode.vue'
import ModalEdge from './components/ModalEdge.vue'
import VSpinner from 'components/spinner.vue'
import { URLParamsToJSON } from 'helpers/url/parse'
import { onMounted } from 'vue'
import { useGraphStore } from './store/useGraphStore.js'

const store = useGraphStore()

onMounted(() => {
  const params = URLParamsToJSON(location.href)
  const biologicalAssociationGraphId = params.biological_assocciations_graph_id
  const coId = params.collection_object_id
  const otuId = params.otu_id

  if (biologicalAssociationGraphId) {
    store.loadGraph(biologicalAssociationGraphId)
  }

  if (coId) {
    store.loadCO(coId)
  }

  if (otuId) {
    store.loadOtu(otuId)
  }
})
</script>

<style scoped>
.graph-section {
  position: relative;
}
</style>
