<template>
  <VMap
    width="100%"
    height="100%"
    style="min-height: 500px"
    :geojson="georeferences"
    resize
  />
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import VMap from 'components/georeferences/map.vue'

const store = useStore()
const georeferences = computed(() => store.getters[GetterNames.GetGeoreferences].map(g => g.geo_json))

</script>
