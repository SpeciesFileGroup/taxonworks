<template>
  <NavBar>
    <span v-html="collectingEvent.objectTag">
      <RadialAnnotator />
      <RadialObject />
      <RadialNavigator />
  </NavBar>
</template>

<script setup>
import NavBar from 'components/layout/NavBar.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/object/radial.vue'
import RadialNavigator from 'components/radials/navigation/radial.vue'
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'

const store = useStore()
const collectingEvent = computed(() => store.getters[GetterNames.GetCollectingEvent])
</script>
