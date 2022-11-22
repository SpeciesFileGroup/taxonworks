<template>
  <div class="panel content">
    <div class="flex-separate middle">
      <h2>Collecting event</h2>
      <VLock v-model="store.settings.lock.collectingEvent"/>
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
import { useStore } from '../store/useStore'
import GeographicArea from './GeographicArea.vue'
import VLock from 'components/ui/VLock/index.vue'

const store = useStore()
</script>
