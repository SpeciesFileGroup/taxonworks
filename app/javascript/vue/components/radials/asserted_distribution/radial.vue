<template>
  <RadialBatch
    v-bind="attrs"
    title="Radial asserted distribution"
    :slices="SLICES"
    :object-type="ASSERTED_DISTRIBUTION"
  />
</template>

<script setup>
import { useAttrs } from 'vue'
import { ASSERTED_DISTRIBUTION } from '@/constants'
import RadialBatch from '@/components/radials/shared/RadialBatch.vue'
import MoveSlice from './components/MoveSlice.vue'

const SLICES = {
  Move: MoveSlice
}

defineOptions({
  name: 'RadialAssertedDistribution'
})

const attrs = useAttrs()
</script>
