<template>
  <h1>New filename depicting image</h1>
  <div class="horizontal-left-content align-start gap-medium">
    <PanelImage v-model="images" />
    <PanelDepictions :images="images" />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import PanelDepictions from './components/PanelDepictions.vue'
import PanelImage from './components/PanelImage.vue'

const images = ref([])
</script>
