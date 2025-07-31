<template>
  <RadialBatch
    v-bind="attrs"
    title="Radial loan"
    icon="picking"
    :slices="SLICES"
    :object-type="COLLECTION_OBJECT"
  />
</template>

<script setup>
import { useAttrs } from 'vue'
import { COLLECTION_OBJECT } from '@/constants'
import RadialBatch from '@/components/radials/shared/RadialBatch.vue'
import AddSlice from './components/AddSlice.vue'
import ReturnSlice from './components/ReturnSlice.vue'
import ReturnAndAddSlice from './components/ReturnAndAddSlice.vue'

const SLICES = {
  Add: AddSlice,
  Return: ReturnSlice,
  'Return and Add': ReturnAndAddSlice
}

defineOptions({
  name: 'RadialLoan'
})

const attrs = useAttrs()
</script>
