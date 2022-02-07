<template>
  <div>
    <h3>Origin</h3>
    <ul class="no_bullets">
      <li>
        <label>
          <input
            type="radio"
            :value="undefined"
            v-model="origin"
          >
          All
        </label>
      </li>
      <li
        v-for="item in options"
        :key="item"
      >
        <label>
          <input
            type="radio"
            v-model="origin"
            :value="item"
          >
          {{ item }}
        </label>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { URLParamsToJSON } from 'helpers/url/parse';
import { ref, computed } from 'vue'
import {
  COLLECTION_OBJECT,
  EXTRACT,
  OTU,
  RANGED_LOT,
  LOT
} from 'constants/index'

const options = [
  COLLECTION_OBJECT,
  EXTRACT,
  OTU,
  RANGED_LOT,
  LOT
]

const props = defineProps({
  modelValue: {
    type: String,
    default: undefined
  }
})

const emit = defineEmits(['update:modelValue'])

const origin = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

origin.value = URLParamsToJSON(location.href).extract_origin

</script>
