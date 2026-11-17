<template>
  <RadialBatch
    v-bind="attrs"
    title="Radial biological associations"
    :slices="SLICES"
    :object-type="BIOLOGICAL_ASSOCIATION"
  />
</template>

<script setup>
import { useAttrs } from 'vue'
import { BIOLOGICAL_ASSOCIATION } from '@/constants'
import RadialBatch from '@/components/radials/shared/RadialBatch.vue'
import RotateSlice from './components/RotateSlice.vue'
import RelationshipSlice from './components/RelationshipSlice.vue'
import AssertedDistributionSlice from '@/components/radials/shared/AssertedDistributionSlice.vue'

const SLICES = {
  Rotate: RotateSlice,
  'Change relationship': RelationshipSlice,
  'Add asserted distribution': AssertedDistributionSlice
}

defineOptions({
  name: 'RadialBiologicalAssociations'
})

const attrs = useAttrs()
</script>
