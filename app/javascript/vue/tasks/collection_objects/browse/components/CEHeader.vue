<template>
  <NavBar>
    <div
      v-if="collectingEvent.id"
      class="flex-separate middle"
    >
      <span v-html="collectingEvent.object_tag" />
      <div class="horizontal-right-content">
        <RadialAnnotator :global-id="collectingEvent.global_id" />
        <RadialObject :global-id="collectingEvent.global_id" />
        <RadialNavigator :global-id="collectingEvent.global_id" />
      </div>
    </div>
  </NavBar>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../store/getters/getters'
import NavBar from 'components/layout/NavBar.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/object/radial.vue'
import RadialNavigator from 'components/radials/navigation/radial.vue'

const store = useStore()
const collectingEvent = computed(() => store.getters[GetterNames.GetCollectingEvent])
</script>
