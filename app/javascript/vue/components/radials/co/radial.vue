<template>
  <RadialBatch
    v-bind="attrs"
    title="Radial collection object"
    :slices="SLICES"
    :object-type="COLLECTION_OBJECT"
  />
</template>

<script setup>
import { useAttrs } from 'vue'
import { COLLECTION_OBJECT } from '@/constants'
import RadialBatch from '@/components/radials/shared/RadialBatch.vue'
import SliceTaxonDetermination from './components/SliceTaxonDetermination.vue'
import SliceBiocurations from './components/SliceBiocurations/SliceBiocurations.vue'
import SliceRepository from './components/SliceRepository.vue'
import SliceCollectingEvent from './components/SliceCollectingEvent.vue'
import SlicePreparationType from './components/SlicePreparationType.vue'
import SliceContainer from './components/SliceContainer.vue'
import DwcSlice from './components/DwCSlice.vue'

const SLICES = {
  'Add biocurations': SliceBiocurations,
  'Collecting event': SliceCollectingEvent,
  Container: SliceContainer,
  'Taxon determinations': SliceTaxonDetermination,
  Repository: SliceRepository,
  'Regenerate DwC': DwcSlice,
  'Preparation type': SlicePreparationType
}

defineOptions({
  name: 'RadialCollectionObject'
})

const attrs = useAttrs()
</script>
