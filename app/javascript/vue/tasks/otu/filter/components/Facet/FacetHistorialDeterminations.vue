<template>
  <FacetContainer>
    <h3>Historical determinations</h3>
    <ul class="no_bullets">
      <li
        v-for="(value, label) in OPTIONS"
        :key="label"
      >
        <label>
          <input
            type="radio"
            :value="value"
            v-model="params.historical_determinations"
          >
          {{ label }}
        </label>
      </li>
    </ul>
  </FacetContainer>
</template>

<script setup>
import { computed } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'

const OPTIONS = {
  'Only current': undefined,
  'Current and historical': false,
  'Only historical': true
}

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

params.value.historical_determinations = URLParamsToJSON(location.href)?.historical_determinations
</script>
