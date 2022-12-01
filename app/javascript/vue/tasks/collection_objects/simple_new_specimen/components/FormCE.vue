<template>
  <div>
    <hr>
    <div class="flex-separate middle">
      <h3>Collecting event</h3>
      <VLock v-model="store.settings.lock.collectingEvent" />
    </div>
    <div class="field label-above">
      <label>Verbatim label</label>
      <textarea
        class="full_width"
        rows="5"
        v-model="store.collectingEvent.verbatim_label"
      />
    </div>
    <div class="field label-above">
      <label>Verbatim locality</label>
      <input
        class="full_width"
        v-model="store.collectingEvent.verbatim_locality"
        type="text"
      >
    </div>
    <GeographicArea />
  </div>
</template>

<script setup>
import { watch } from 'vue'
import { useStore } from '../store/useStore'
import GeographicArea from './GeographicArea.vue'
import VLock from 'components/ui/VLock/index.vue'

const store = useStore()

watch(
  [
    () => store.geographicArea,
    store.collectingEvent
  ],
  () => {
    store.createdCE = undefined
  },
  { deep: true }
)

watch(
  () => store.settings.lock.collectingEvent,
  newVal => {
    if (!newVal) {
      store.$patch({
        collectingEvent: {
          verbatim_locality: undefined,
          verbatim_label: undefined
        },
        geographicArea: undefined
      })
    }
  }
)
</script>
