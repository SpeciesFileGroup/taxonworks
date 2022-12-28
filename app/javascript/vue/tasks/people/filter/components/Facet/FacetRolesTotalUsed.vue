<template>
  <FacetContainer>
    <div class="field label-above">
      <label>Used more than</label>
      <input
        v-model="params.role_total_min"
        type="number"
        class="input-xsmall-width"
      >
    </div>
    <div class="field label-above">
      <label>Used less than</label>
      <input
        v-model="params.role_total_max"
        type="number"
        class="input-xsmall-width"
      >
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { computed } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,

  set: value => {
    emit('update:modelValue', value)
  }
})

const urlParams = URLParamsToJSON(location.href)

Object.assign(params.value, {
  role_total_min: urlParams.role_total_min,
  role_total_max: urlParams.role_total_max
})
</script>
