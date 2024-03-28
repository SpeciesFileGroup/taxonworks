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
import VerbatimSlice from './components/VerbatimAuthorSlice.vue'

const SLICES = {
  Parent: SliceParent,
  Verbatim: VerbatimSlice
}

defineOptions({
  name: 'RadialNomenclature'
})

const attrs = useAttrs()
</script>
