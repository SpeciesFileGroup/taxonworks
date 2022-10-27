<template>
  <NavBar>
    <div
      v-if="collectionObject.id"
      class="flex-separate middle"
    >
      <span v-html="collectionObject.objectTag" />
      <div class="horizontal-right-content">
        <RadialAnnotator :global-id="collectionObject.globalId" />
        <RadialObject :global-id="collectionObject.globalId" />
        <RadialNavigator :global-id="collectionObject.globalId" />
        <RadialFilter object-type="CollectionObject" />
      </div>
      <RadialFilterAttribute :parameters="{ collection_object_id: [collectionObject.id] }" />
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
import RadialFilter from 'components/radials/filter/radial.vue'
import RadialFilterAttribute from 'components/radials/filter/RadialFilterAttribute.vue'

const store = useStore()
const collectionObject = computed(() => store.getters[GetterNames.GetCollectionObject])
</script>
