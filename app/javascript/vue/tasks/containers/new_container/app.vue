<template>
  <h1>New container</h1>
  <div
    class="horizontal-left-content align-start full_width task-container gap-medium"
  >
    <div>
      <ContainerForm
        v-model="container"
        class="container-form margin-medium-bottom"
        @new="newContainer"
        @save="saveContainer"
      />
      <ContainerItems :container-items="container.containerItems" />
    </div>

    <VueEncase
      class="container-viewer"
      v-bind="opts"
    />
  </div>
</template>

<script setup>
import { VueEncase } from '@sfgrp/encase'
import { computed, ref, onBeforeMount } from 'vue'
import { useContainer } from './composables'
import { URLParamsToJSON } from '@/helpers'
import ContainerForm from './components/ContainerForm.vue'
import ContainerItems from './components/ContainerItems.vue'

const DEFAULT_OPTS = {
  enclose: true,
  itemSize: 1,
  padding: 1
}

defineOptions({
  name: 'NewContainer'
})

const { container, loadContainer, newContainer, saveContainer } = useContainer()

const opts = computed(() => ({
  ...DEFAULT_OPTS,
  container: {
    type: container.value.type,
    sizeX: container.value.size.x,
    sizeY: container.value.size.y,
    sizeZ: container.value.size.z,
    containerItems: []
  }
}))

const selectedItems = ref([])

onBeforeMount(() => {
  const { container_id } = URLParamsToJSON(window.location.href)

  if (container_id) {
    loadContainer(container_id)
  }
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
