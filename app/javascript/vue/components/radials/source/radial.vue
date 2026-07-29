<template>
  <RadialBatch
    v-bind="attrs"
    title="Radial source"
    :slices="SLICES"
    :object-type="SOURCE"
  >
    <template #icon>
      <IconSource class="w-3.5 h-3.5" />
    </template>
  </RadialBatch>
</template>

<script setup>
import { useAttrs } from 'vue'
import { SOURCE } from '@/constants'
import RadialBatch from '@/components/radials/shared/RadialBatch.vue'
import SliceSerial from './components/SliceSerial.vue'
import SliceProjectSource from './components/SliceProjectSource.vue'
import IconSource from '@/components/Icon/IconSource.vue'

const SLICES = {
  Serial: SliceSerial,
  'Project source': SliceProjectSource
}

defineOptions({
  name: 'RadialSource'
})

const attrs = useAttrs()
</script>
