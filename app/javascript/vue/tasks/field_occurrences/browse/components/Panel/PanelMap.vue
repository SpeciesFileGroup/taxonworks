<template>
  <VMap
    width="100%"
    height="100%"
    style="min-height: 500px"
    :geojson="geoJson"
    resize
  />
</template>

<script setup>
import useGeoreferencesStore from '../../store/collectingEvent.js'
import { computed } from 'vue'
import VMap from '@/components/georeferences/map.vue'

const store = useGeoreferencesStore()
const georeferences = computed(() => store.georeferences.map((g) => g.geo_json))

const geoJson = computed(() =>
  store.geographicArea?.shape
    ? [store.geographicArea.shape, ...georeferences.value]
    : [...georeferences.value]
)
</script>
