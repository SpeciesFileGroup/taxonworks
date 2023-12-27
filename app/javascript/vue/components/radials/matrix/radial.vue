<template>
  <RadialBatch
    v-bind="attrs"
    title="Radial matrix"
    :slices="SLICES"
    icon="matrix"
    nested-query
  />
</template>

<script setup>
import { useAttrs } from 'vue'
import RadialBatch from '@/components/radials/shared/RadialBatch.vue'
import AddSlice from './components/AddSlice.vue'
import AddNewSlice from './components/AddNewSlice.vue'

const SLICES = {
  'Add to an existing matrix': AddSlice,
  'Add to a new matrix': AddNewSlice
}

defineOptions({
  name: 'RadialMatrix'
})

const attrs = useAttrs()
</script>
