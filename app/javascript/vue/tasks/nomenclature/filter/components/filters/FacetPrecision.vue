<template>
  <FacetContainer>
    <h3>Precision</h3>
    <label>
      <input
        v-model="params.exact"
        type="checkbox"
      >
      Exact match only
    </label>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import { computed, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

onBeforeMount(() => {
  params.value.exact = URLParamsToJSON(location.href).exact
})

</script>
