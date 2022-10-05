<template>
  <div>
    <label>
      Amount:
      <input
        type="number"
        v-model="observation.continuousValue"
      >
    </label>
    <UnitSelector
      class="margin-small-right"
      v-model="observation.continuousUnit"
    />
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
