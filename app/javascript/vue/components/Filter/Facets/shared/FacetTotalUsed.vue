<template>
  <FacetContainer>
    <h3>Usage</h3>
    <div class="field label-above">
      <label>Used more than</label>
      <input
        v-model="params.use_min"
        type="number"
        class="input-xsmall-width"
      />
    </div>
    <div class="field label-above">
      <label>Used less than</label>
      <input
        v-model="params.use_max"
        type="number"
        class="input-xsmall-width"
      />
    </div>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import { computed } from 'vue'
import { URLParamsToJSON } from '@/helpers/url/parse'

const props = defineProps({
  modelValue: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,

  set: (value) => {
    emit('update:modelValue', value)
  }
})

const urlParams = URLParamsToJSON(location.href)

Object.assign(params.value, {
  use_min: urlParams.use_min,
  use_max: urlParams.use_max
})
</script>
