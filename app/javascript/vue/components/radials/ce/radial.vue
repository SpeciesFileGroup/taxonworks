<template>
  <RadialBatch
    v-bind="attrs"
    title="Radial collecting event"
    :slices="SLICES"
    :object-type="COLLECTING_EVENT"
  />
</template>

<script setup>
import { useAttrs } from 'vue'
import { COLLECTING_EVENT } from '@/constants'
import RadialBatch from '@/components/radials/shared/RadialBatch.vue'
import AssignSlice from './components/AssignSlice.vue'
import CollectorSlice from './components/CollectorSlice.vue'
import DateTimeSlice from '@/components/radials/ce/components/DateTimeSlice.vue'

const SLICES = {
  'Assign/Move': AssignSlice,
  'Append New Collectors': CollectorSlice,
  'Set Collection Date/Time': DateTimeSlice
}

defineOptions({
  name: 'RadialCollectingEvent'
})

const attrs = useAttrs()
</script>
