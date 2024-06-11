<template>
  <h1>New container</h1>
  <div
    class="horizontal-left-content align-start full_width task-container gap-medium"
  >
    <div>
      <ContainerForm
        v-model="store.container"
        class="container-form margin-medium-bottom"
        @new="store.newContainer"
        @save="store.saveContainer"
      />
      <ContainerItemList :container-items="store.containerItems" />
    </div>

    <VueEncase
      class="container-viewer"
      v-bind="store.encaseOpts"
      @container-item:right-click="openContainerItemModal"
    />
    <ContainerItemModal
      ref="containerItemModalRef"
      @add="
        (item) => {
          store.addContainerItem(item)
          store.saveContainerItems()
        }
      "
      @remove="store.removeContainerItem"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { VueEncase } from '@sfgrp/encase'
import { onBeforeMount } from 'vue'
import { URLParamsToJSON } from '@/helpers'
import { useContainerStore } from './store'
import { makeContainerItem } from './adapters'
import ContainerForm from './components/ContainerForm.vue'
import ContainerItemList from './components/ContainerItem/ContainerItemList.vue'
import ContainerItemModal from './components/ContainerItem/ContainerItemModal.vue'

defineOptions({
  name: 'NewContainer'
})

const store = useContainerStore()
const containerItemModalRef = ref()

async function openContainerItemModal({ position }) {
  const containerItem = store.getContainerItemByPosition(position) || {
    ...makeContainerItem(),
    position
  }

  await new Promise((resolve) => setTimeout(resolve, 50))

  containerItemModalRef.value.show(containerItem)
}

onBeforeMount(() => {
  const { container_id } = URLParamsToJSON(window.location.href)

  if (container_id) {
    store.loadContainer(container_id)
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
