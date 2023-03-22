<template>
  <FacetContainer>
    <h3>Buffered</h3>
    <div
      v-for="param in bufferedParameters"
      class="field label-above"
      :key="param"
    >
      <label class="capitalize">{{ param.replace('buffered_', '').replace(/_/g, ' ') }}</label>
      <input
        class="full_width"
        v-model="params[param]"
        type="text"
      >
      <label>
        <input
          v-model="params[`exact_${param}`]"
          type="checkbox"
        >
        Exact
      </label>
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { computed, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'

const bufferedParameters = [
  'buffered_collecting_event',
  'buffered_determinations',
  'buffered_other_labels'
]

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: value => emit('update:modelValue', value)
})

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  bufferedParameters.forEach(param => {
    params.value[param] = urlParams[param]
    params.value[`exact_${param}`] = urlParams[`exact_${param}`]
  })
})
</script>
