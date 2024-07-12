<template>
  <div class="task-container">
    <h1>Uniquify objects</h1>

    <PanelObject />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import PanelObject from './components/PanelObject.vue'
</script>

<style scoped>
.task-container {
  width: 1240px;
  margin: 0 auto;
}
</style>
