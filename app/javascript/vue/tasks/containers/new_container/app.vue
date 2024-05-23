<template>
  <h1>New container</h1>
  <div
    class="horizontal-left-content align-start full_width task-container gap-medium"
  >
    <ContainerForm
      v-model="container"
      class="container-form"
    />

    <VueEncase
      class="container-viewer"
      v-bind="opts"
      :container="container"
      v-model:selected-items="selectedItems"
    />
  </div>
</template>

<script setup>
import { VueEncase } from '@sfgrp/encase'
import { ref } from 'vue'
import ContainerForm from './components/ContainerForm.vue'

const selectedItems = ref([])
const container = ref({
  name: '',
  sizeX: 12,
  sizeY: 1,
  sizeZ: 8,
  containerItems: []
})

const opts = ref({
  enclose: true,
  itemSize: 1,
  padding: 1
})
</script>

<style lang="scss" scoped>
.container-viewer {
  width: 100%;
  height: 100%;

  :deep(canvas) {
    border-radius: inherit;
  }
}

.container-form {
  width: 400px;
}

.task-container {
  height: calc(100vh - 200px);
  max-height: calc(100vh - 200px);
}
</style>
