<template>
  <FacetContainer>
    <h3>Times repeated</h3>
    <input
      v-model="params.repeated_total"
      type="number"
      class="input-xsmall-width"
    >
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { computed } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse'

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

params.value.repeated_total = URLParamsToJSON(location.href).repeated_total
</script>
