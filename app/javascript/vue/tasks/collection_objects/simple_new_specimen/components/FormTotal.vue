<template>
  <div>
    <label>Total</label>
    <div class="horizontal-left-content align-start">
      <input
        class="input-xsmall-width"
        type="number"
        min="1"
        v-model.number="total"
        :data-locked="store.settings.lock.total"
      />
      <VLock
        class="margin-small-left"
        v-model="store.settings.lock.total"
      />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from '../store/useStore'
import VLock from '@/components/ui/VLock/index.vue'

const store = useStore()

const total = computed({
  get: () => store.total,
  set: (value) => {
    store.total = value > 1 ? value : 1
  }
})
</script>
