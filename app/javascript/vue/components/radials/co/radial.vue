<template>
  <RadialBatch
    v-bind="attrs"
    title="Radial collection object"
    :slices="SLICES"
    :object-type="COLLECTION_OBJECT"
  />
</template>

<script setup>
import { computed, useAttrs } from 'vue'
import { COLLECTION_OBJECT } from '@/constants'
import RadialBatch from '@/components/radials/shared/RadialBatch.vue'
import SliceTaxonDetermination from './components/SliceTaxonDetermination.vue'
import SliceBiocurations from './components/SliceBiocurations/SliceBiocurations.vue'
import SliceRepository from './components/SliceRepository.vue'
import SliceCollectingEvent from './components/SliceCollectingEvent.vue'
import SlicePreparationType from './components/SlicePreparationType.vue'
import SliceContainerItems from './components/SliceContainerItems.vue'
import DwcSlice from './components/DwCSlice.vue'
import SliceAccessions from './components/SliceAccessions.vue'
import SliceTypeMaterial from './components/SliceTypeMaterial.vue'

defineOptions({
  name: 'RadialCollectionObject'
})

const attrs = useAttrs()

// Setting a type designation on the full, unbounded set of unchecked filter
// results is too easy to trigger by accident, so this slice is only offered
// against an explicit, checked selection (see RadialLinker's isOnlyIds).
const isOnlyIds = computed(() => Array.isArray(attrs.ids))

const SLICES = computed(() => ({
  'Add biocurations': SliceBiocurations,
  'Accessions / Deaccession': SliceAccessions,
  'Collecting event': SliceCollectingEvent,
  'Container items': SliceContainerItems,
  'Taxon determinations': SliceTaxonDetermination,
  Repository: SliceRepository,
  'Regenerate DwC': DwcSlice,
  'Preparation type': SlicePreparationType,
  ...(isOnlyIds.value ? { 'Type material': SliceTypeMaterial } : {})
}))
</script>
