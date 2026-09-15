<template>
  <RadialBatch
    v-bind="attrs"
    title="Radial taxon name"
    :slices="slices"
    :object-type="TAXON_NAME"
  />
</template>

<script setup>
import { computed, useAttrs } from 'vue'
import { TAXON_NAME } from '@/constants'
import RadialBatch from '@/components/radials/shared/RadialBatch.vue'
import GenderSlice from './components/GenderSlice.vue'
import SliceParent from './components/ParentSlice.vue'
import StatusSlice from './components/StatusSlice.vue'
import VerbatimSlice from './components/VerbatimSlice.vue'

const SLICES = {
  Gender: GenderSlice,
  Parent: SliceParent,
  Verbatim: VerbatimSlice
}

// Status is only offered on the checkboxed (ids-based) radial, not the
// whole-filter-result one, since a fixed citation is attached per selection.
const SLICES_WITH_STATUS = {
  Gender: GenderSlice,
  Parent: SliceParent,
  Status: StatusSlice,
  Verbatim: VerbatimSlice
}

defineOptions({
  name: 'RadialNomenclature'
})

const attrs = useAttrs()
const slices = computed(() => ('ids' in attrs ? SLICES_WITH_STATUS : SLICES))
</script>
