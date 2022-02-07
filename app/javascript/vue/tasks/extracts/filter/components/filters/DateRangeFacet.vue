<template>
  <div>
    <h3>Date</h3>
    <div class="horizontal-left-content">
      <div class="field separate-right label-above">
        <label>Start date</label>
        <input
          type="date"
          v-model="startDate"
        >
      </div>

      <div class="field label-above">
        <label>End date</label>
        <input
          type="date"
          v-model="endDate"
        >
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  start: {
    type: String,
    default: undefined
  },

  end: {
    type: String,
    default: undefined
  }
})

const emit = defineEmits([
  'update:start',
  'update:end'
])

const startDate = computed({
  get: () => props.start,
  set: value => emit('update:start', value)
})

const endDate = computed({
  get: () => props.end,
  set: value => emit('update:end', value)
})

</script>
