<template>
  <VMap
    :geojson="georeferences"
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
