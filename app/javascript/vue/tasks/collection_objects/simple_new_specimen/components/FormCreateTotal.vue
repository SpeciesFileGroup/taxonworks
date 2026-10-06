<template>
  <div class="horizontal-left-content middle gap-small">
    <label for="create-total">Create</label>
    <input
      id="create-total"
      class="input-xsmall-width"
      type="text"
      pattern="\d*"
      maxlength="2"
      v-model.number="total"
    />
    <span>{{ label }}</span>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from '../store/useStore'

const MAX_TOTAL = 20

const store = useStore()

const total = computed({
  get: () => store.createTotal,
  set: (value) => {
    if (value > MAX_TOTAL) {
      store.createTotal = MAX_TOTAL
    } else if (value < 1) {
      store.createTotal = 1
    } else {
      store.createTotal = value
    }
  }
})

const label = computed(() => {
  const noun = store.total > 1 ? 'lot' : 'specimen'

  return store.createTotal > 1 ? `${noun}s` : noun
})
</script>
