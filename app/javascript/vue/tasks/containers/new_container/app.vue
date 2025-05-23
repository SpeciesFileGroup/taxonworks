<template>
  <div class="app-container">
    <div class="flex-separate middle">
      <h1>New container</h1>
      <VSettings />
    </div>
    <VSpinner
      v-if="store.isLoading"
      full-screen
    />
    <VSpinner
      v-if="store.isSaving"
      legend="Saving..."
    />
    <Navbar />
    <div class="task-container">
      <div class="flex-col gap-medium left-column full_height">
        <ContainerForm
          v-model="store.container"
          class="full_width"
        />

        <div class="overflow-y-auto">
          <TableObject />
          <VSwitch
            class="margin-medium-top"
            :options="tabs"
            use-index
            v-model.number="listView"
          />
          <ContainerItemList
            v-if="listView === TAB_INDEX.Unplaced"
            fill-button
            title="Objects (In)"
            :list="store.getItemsOutsideContainer"
            @edit="openContainerItemModal"
          />
          <ContainerItemList
            v-if="listView === TAB_INDEX.Placed"
            title="Objects (In)"
            unplace-button
            :list="store.getItemsInsideContainer"
            @edit="openContainerItemModal"
          />
        </div>
      </div>

      <VueEncase
        class="container-viewer"
        v-bind="store.encaseOpts"
        v-model:selected-items="store.selectedItems"
        @container-item:left-click="handleClick"
        @container-item:right-click="
          (item) => {
            openContainerItemModal({
              position: convertPositionToTWCoordinates(
                item.position,
                store.container.size
              )
            })
          }
        "
      />
    </div>
  </div>
  <ContainerItemModal
    ref="containerItemModalRef"
    :container-id="store.container.id"
    @close="() => (store.placeItem = null)"
    @add="saveContainerItem"
    @remove="store.removeContainerItem"
  />

  <MessageBox />
</template>

<script setup>
import { ref, computed } from 'vue'
import { VueEncase } from '@sfgrp/encase'
import { onBeforeMount } from 'vue'
import { URLParamsToJSON } from '@/helpers'
import { useContainerStore } from './store'
import { makeContainerItem } from './adapters'
import { convertPositionToTWCoordinates } from './utils'
import VSwitch from '@/components/ui/VSwitch.vue'
import ContainerForm from './components/ContainerForm.vue'
import ContainerItemList from './components/ContainerItem/ContainerItemList.vue'
import ContainerItemModal from './components/ContainerItem/ContainerItemModal.vue'
import Navbar from './components/Navbar/Navbar.vue'
import MessageBox from './components/MessageBox.vue'
import VSettings from './components/Settings.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import TableObject from './components/TableObject.vue'

const TAB_INDEX = {
  Unplaced: 0,
  Placed: 1
}

const tabs = computed(() => ({
  [TAB_INDEX.Unplaced]: `Unplaced (${store.getItemsOutsideContainer.length})`,
  [TAB_INDEX.Placed]: `Placed (${store.getItemsInsideContainer.length})`
}))

defineOptions({
  name: 'NewContainer'
})

const store = useContainerStore()
const containerItemModalRef = ref()
const listView = ref(TAB_INDEX.Unplaced)

async function openContainerItemModal({ position }) {
  const containerItem = store.getContainerItemByPosition(position) || {
    ...makeContainerItem(),
    position
  }

  await new Promise((resolve) => setTimeout(resolve, 50))

  containerItemModalRef.value.show(containerItem)
}

function handleClick({ position }) {
  const twPosition = convertPositionToTWCoordinates(
    position,
    store.container.size
  )

  if (store.placeItem && !store.getContainerItemByPosition(twPosition)) {
    const containerItem = {
      ...store.placeItem,
      position: twPosition,
      isUnsaved: true
    }

    containerItemModalRef.value.show(containerItem)
  }
}

async function saveContainerItem(item) {
  if (store.container.isUnsaved) {
    try {
      await store.saveContainer()
    } catch {
      return
    }
  }

  store.addContainerItem(item)
  store.saveContainerItems()
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
  position: relative;
  width: 100%;
  height: 100%;
  box-sizing: border-box;

  :deep(canvas) {
    border-radius: inherit;
  }
}

.app-container {
  max-height: calc(100vh - 16rem);
  height: calc(100vh - 16rem);
}

.left-column {
  width: 430px;
  min-width: 430px;
}

.container-form {
  min-width: 100%;
  width: 100%;
}

.task-container {
  overflow-y: hidden;
  position: relative;
  height: 100%;
  display: flex;
  gap: 1em;
}
</style>
