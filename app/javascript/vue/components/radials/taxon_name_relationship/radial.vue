<template>
  <RadialBatch
    v-bind="attrs"
    title="Radial taxon name relationships"
    :slices="SLICES"
    :object-type="TAXON_NAME_RELATIONSHIP"
  />
</template>

<script setup>
import { useAttrs } from 'vue'
import { TAXON_NAME_RELATIONSHIP } from '@/constants'
import RadialBatch from '@/components/radials/shared/RadialBatch.vue'
import SynonymTypeSlice from './components/SynonymTypeSlice.vue'

defineOptions({
  name: 'RadialTaxonNameRelationship'
})

const SLICES = {
  'Update synonym type': SynonymTypeSlice
}

const attrs = useAttrs()
</script>
