<template>
  <FacetContainer>
    <h3>Origin</h3>
    <ul class="no_bullets">
      <li>
        <label>
          <input
            type="radio"
            :value="undefined"
            v-model="params.extract_origin"
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
            v-model="params.extract_origin"
            :value="item"
          >
          {{ item }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { URLParamsToJSON } from 'helpers/url/parse'
import { computed } from 'vue'
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
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

params.value.extract_origin = URLParamsToJSON(location.href).extract_origin

</script>
