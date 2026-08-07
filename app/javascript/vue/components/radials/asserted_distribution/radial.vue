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
import DwCSlice from './components/DwCSlice.vue'
import ReplaceSourcesSlice from './components/ReplaceSourcesSlice.vue'

const SLICES = {
  Move: MoveSlice,
  'Replace source': ReplaceSourcesSlice
  //'Regenerate DwC': DwCSlice
}

defineOptions({
  name: 'RadialAssertedDistribution'
})

const attrs = useAttrs()
</script>
