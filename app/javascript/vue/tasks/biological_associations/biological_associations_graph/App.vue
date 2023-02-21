<template>
  <div>
    <h1>Biological associations graph</h1>
    <VNavbar />
    <section class="graph-section">
      <NetworkCanvas />
    </section>
  </div>
</template>

<script setup>
import NetworkCanvas from './components/NetworkCanvas.vue'
import VNavbar from './components/Navbar.vue'
</script>

<style scoped>
.graph-section {
  position: relative;
}
</style>
