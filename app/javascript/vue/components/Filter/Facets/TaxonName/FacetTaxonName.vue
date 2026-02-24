<template>
  <FacetContainer>
    <h3>Taxon name</h3>
    <slot name="top"></slot>
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
    <FacetCurrentDetermination
      v-if="currentDetermination"
      v-model="params"
      param-name="taxon_name_current_determination"
      header-text="Determination"
    />
    <slot name="bottom"></slot>
  </FacetContainer>
</template>

<script setup>
import FacetContainer from '@/components/Filter/Facets/FacetContainer.vue'
import TaxonNameSelector from './components/TaxonNameSelector.vue'
import IncludeSelector from './components/IncludeSelector.vue'
import CoverageSelector from './components/ConverageSelector.vue'
import ValiditySelector from './components/ValiditySelector.vue'
import TaxonNameMode from './components/TaxonNameMode.vue'
import FacetCurrentDetermination from '@/components/Filter/Facets/shared/FacetCurrentDetermination.vue'
import { computed } from 'vue'

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
  },

  currentDetermination: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue'])

const params = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

</script>
