<template>
  <div class="task-container">
    <div class="flex-separate middle">
      <h1>New filename depicting image</h1>
    </div>
    <div class="flexbox gap-medium">
      <PanelImage
        v-model="images"
        v-model:error="error"
      />
      <PanelDepictions v-model="images" />
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import PanelDepictions from './components/PanelDepictions.vue'
import PanelImage from './components/PanelImage.vue'

const images = ref([])
const error = ref([])
</script>

<style scoped>
.task-container {
  margin: 0 auto;
  max-width: 1240px;
}
</style>
