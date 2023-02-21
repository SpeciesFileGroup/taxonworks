<template>
  <div>
    <h1>Biological associations graph</h1>
    <section class="graph-section">
      <NetworkCanvas />
      <VRelationship />
    </section>
  </div>
</template>

<script setup>
import NetworkCanvas from './components/NetworkCanvas.vue'
import VRelationship from './components/Relationship.vue'
</script>

<style scoped>
.graph-section {
  position: relative;
}
</style>
