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
import { OTU } from '@/constants'
import { useAttrs } from 'vue'
import RadialBatch from '@/components/radials/shared/RadialBatch.vue'
import AddSlice from './components/AddSlice.vue'
import AddNewSlice from './components/AddNewSlice.vue'
import ImageMatrix from './components/ImageMatrix.vue'

const attrs = useAttrs()
const props = defineProps({
  objectType: {
    type: String,
    default: undefined
  }
})

const SLICES = {
  'Add to an existing matrix': AddSlice,
  'Add to a new matrix': AddNewSlice
}

if (attrs.ids && props.objectType === OTU) {
  Object.assign(SLICES, {
    'View image matrix': ImageMatrix
  })
}

defineOptions({
  name: 'RadialMatrix'
})
</script>
