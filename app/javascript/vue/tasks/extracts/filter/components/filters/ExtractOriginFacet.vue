<template>
  <div>
    <h3>Origin</h3>
    <select v-model="origin">
      <option
        v-for="item in options"
        :value="item"
        :key="item"
      >
        {{ item }}
      </option>
    </select>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import {
  COLLECTION_OBJECT,
  EXTRACT,
  OTU,
  RANGED_LOT,
  LOT
} from 'constants/index'

const options = ref([
  COLLECTION_OBJECT,
  EXTRACT,
  OTU,
  RANGED_LOT,
  LOT
])

const props = defineProps({
  modelValue: {
    type: String,
    default: undefined
  }
})

const origin = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})
</script>
