<template>
  <FacetContainer>
    <h3>Taxon name</h3>
    <TaxonNameSelector
      v-model="params"
      :relation="relation"
    />
    <TaxonNameMode
      v-if="mode"
      v-model="params"
    />
    <CoverageSelector
      v-if="coverage"
      v-model="params"
    />
    <IncludeSelector
      v-if="include"
      v-model="params"
    />
    <ValiditySelector
      v-if="validity"
      v-model="params"
    />
  </FacetContainer>
</template>

<script setup>
import FacetContainer from 'components/Filter/Facets/FacetContainer.vue'
import TaxonNameSelector from './components/TaxonNameSelector.vue'
import IncludeSelector from './components/IncludeSelector.vue'
import CoverageSelector from './components/ConverageSelector.vue'
import ValiditySelector from './components/ValiditySelector.vue'
import TaxonNameMode from './components/TaxonNameMode.vue'
import { computed, onBeforeMount } from 'vue'
import { URLParamsToJSON } from 'helpers/url/parse.js'

const props = defineProps({
  modelValue: {
    type: Object,
    default: undefined
  },

  coverage: {
    type: Boolean,
    default: false
  },

  include: {
    type: Boolean,
    default: false
  },

  relation: {
    type: Boolean,
    default: false
  },

  validity: {
    type: Boolean,
    default: false
  },

  mode: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

onBeforeMount(() => {
  const urlParams = URLParamsToJSON(location.href)

  params.value.descendants = urlParams.descendants
  params.value.ancestors = urlParams.ancestors
  params.value.validity = urlParams.validity
})
</script>
