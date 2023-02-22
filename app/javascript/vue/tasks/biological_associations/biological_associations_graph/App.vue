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
  </div>
</template>

<script setup>
import NetworkCanvas from './components/NetworkCanvas.vue'
import VNavbar from './components/Navbar.vue'
import ModalNode from './components/ModalNode.vue'
import ModalEdge from './components/ModalEdge.vue'
import { useGraphStore } from './store/useGraphStore.js'

const store = useGraphStore()
</script>

<style scoped>
.graph-section {
  position: relative;
}
</style>
