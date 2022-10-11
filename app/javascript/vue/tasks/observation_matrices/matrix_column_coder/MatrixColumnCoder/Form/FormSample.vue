<template>
  <div class="sample-descriptor">
    <div class="horizontal-left-content margin-small-bottom">
      <label class="separate-right">
        Min:
        <input
          type="number"
          size="8"
          v-model="observation.min"
        >
      </label>
      <label class="separate-left">
        Max:
        <input
          type="number"
          size="8"
          v-model="observation.max"
        >
      </label>

      <unit-selector v-model="observation.units" />

      <label class="separate-left">
        n:
        <input
          type="number"
          size="8"
          v-model="observation.n"
        >
      </label>
    </div>

    <div class="margin-small-bottom">
      <label class="separate-right">
        Mean:
        <input
          type="text"
          size="8"
          v-model="observation.mean"
        >
      </label>
      <label class="separate-right">
        Median:
        <input
          type="text"
          size="8"
          v-model="observation.median"
        >
      </label>
      <label class="separate-right">
        Standard deviation:
        <input
          type="text"
          size="8"
          v-model="observation.standardDeviation"
        >
      </label>
      <label class="separate-right">
        Standard error:
        <input
          type="text"
          size="8"
          v-model="observation.standardError"
        >
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
  set: value => emit('update:modelValue', value)
})

</script>
