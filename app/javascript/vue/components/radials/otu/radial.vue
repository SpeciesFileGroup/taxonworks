<template>
  <RadialBatch
    v-bind="attrs"
    title="Radial OTU"
    :slices="SLICES"
    :object-type="OTU"
  />
</template>

<script setup>
import { h, useAttrs } from 'vue'
import { OTU } from '@/constants'
import RadialBatch from '@/components/radials/shared/RadialBatch.vue'
import TaxonNameSlice from './components/TaxonNameSlice.vue'
import AssertedDistributionSlice from './components/AssertedDistributionSlice.vue'
import AssertedEnvironmentSlice from '@/components/radials/shared/AssertedEnvironmentSlice.vue'

const SLICES = {
  'Update Taxon name': TaxonNameSlice,
  'Add asserted distribution': AssertedDistributionSlice,
  'Add asserted environment': (attrs) =>
    h(AssertedEnvironmentSlice, { ...attrs, objectType: OTU })
}

defineOptions({
  name: 'RadialOtu'
})

const attrs = useAttrs()
</script>
