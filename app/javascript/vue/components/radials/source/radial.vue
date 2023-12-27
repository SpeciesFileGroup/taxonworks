<template>
  <RadialBatch
    v-bind="attrs"
    title="Radial source"
    :slices="SLICES"
    :object-type="SOURCE"
  />
</template>

<script setup>
import { useAttrs } from 'vue'
import { SOURCE } from '@/constants'
import RadialBatch from '@/components/radials/shared/RadialBatch.vue'
import SliceSerial from './components/SliceSerial.vue'

const SLICES = {
  Serial: SliceSerial
}

defineOptions({
  name: 'RadialSource'
})

const attrs = useAttrs()
</script>
