<template>
  <div class="field">
    <label>Create total</label>
    <br>
    <input
      class="input-xsmall-width"
      type="text"
      pattern="\d*"
      maxlength="2"
      v-model.number="total"
    >
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from '../store/useStore'

const MAX_TOTAL = 20

const store = useStore()

const total = computed({
  get: () => store.createTotal,
  set: value => {
    if (value > MAX_TOTAL) {
      store.createTotal = MAX_TOTAL
    } else if (value < 1) {
      store.createTotal = 1
    } else {
      store.createTotal = value
    }
  }
})

</script>
