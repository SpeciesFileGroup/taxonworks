<template>
  <div class="sample-descriptor">
    <div class="horizontal-left-content margin-small-bottom gap-small">
      <label>
        Min:
        <input
          type="number"
          size="8"
          v-model="observation.min"
        />
      </label>
      <label>
        Max:
        <input
          type="number"
          size="8"
          v-model="observation.max"
        />
      </label>

      <unit-selector v-model="observation.units" />

      <label>
        n:
        <input
          type="number"
          size="8"
          v-model="observation.n"
        />
      </label>
    </div>

    <div class="horizontal-left-content gap-small">
      <label>
        Mean:
        <input
          type="text"
          size="8"
          v-model="observation.mean"
        />
      </label>
      <label>
        Median:
        <input
          type="text"
          size="8"
          v-model="observation.median"
        />
      </label>
      <label>
        Standard deviation:
        <input
          type="text"
          size="8"
          v-model="observation.standardDeviation"
        />
      </label>
      <label>
        Standard error:
        <input
          type="text"
          size="8"
          v-model="observation.standardError"
        />
      </label>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import UnitSelector from '../UnitSelector/UnitSelector.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const observation = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})
</script>
