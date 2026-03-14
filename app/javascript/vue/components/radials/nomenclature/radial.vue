<template>
  <RadialBatch
    v-bind="attrs"
    title="Radial nomenclature"
    :slices="SLICES"
    :object-type="TAXON_NAME"
  />
</template>

<script setup>
import { useAttrs } from 'vue'
import { TAXON_NAME } from '@/constants'
import RadialBatch from '@/components/radials/shared/RadialBatch.vue'
import SliceParent from './components/ParentSlice.vue'
import VerbatimSlice from './components/VerbatimSlice.vue'
import GenderSlice from './components/GenderSlice.vue'
import FossilSlice from './components/FossilSlice.vue'

const SLICES = {
  Fossil: FossilSlice,
  Gender: GenderSlice,
  Parent: SliceParent,
  Verbatim: VerbatimSlice
}

defineOptions({
  name: 'RadialNomenclature'
})

const attrs = useAttrs()
</script>
