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
import AddNewKeySlice from './components/AddNewKeySlice.vue'
import AddExistingKeySlice from './components/AddExistingKeySlice.vue'

const attrs = useAttrs()

const SLICES = {
  'Add to an existing matrix': AddSlice,
  'Add to a new matrix': AddNewSlice,
  'Add to an existing key': AddExistingKeySlice,
  'Add to a new key': AddNewKeySlice,
}

defineOptions({
  name: 'RadialMatrix'
})
</script>
