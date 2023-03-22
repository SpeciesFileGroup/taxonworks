<template>
  <VMap
    width="100%"
    height="100%"
    style="min-height: 500px"
    :geojson="geoJson"
    resize
  />
  <RadialFilterAttribute
    v-if="geographicArea.id"
    :parameters="{ geographic_area_id: [geographicArea.id] }"
  />
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import VMap from 'components/georeferences/map.vue'
import RadialFilterAttribute from 'components/radials/linker/RadialFilterAttribute.vue'

const store = useStore()
const georeferences = computed(() => store.getters[GetterNames.GetGeoreferences].map(g => g.geo_json))
const geographicArea = computed(() => store.getters[GetterNames.GetGeographicArea])

const geoJson = computed(() =>
  geographicArea.value?.shape
    ? [geographicArea.value.shape, ...georeferences.value]
    : [...georeferences.value]
)

</script>
