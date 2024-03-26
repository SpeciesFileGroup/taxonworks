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
import SliceProjectSource from './components/SliceProjectSource.vue'

const SLICES = {
  Serial: SliceSerial,
  'Project source': SliceProjectSource
}

defineOptions({
  name: 'RadialSource'
})

const attrs = useAttrs()
</script>
