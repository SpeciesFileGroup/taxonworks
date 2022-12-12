<template>
  <NavBar>
    <div
      v-if="collectionObject.id"
      class="flex-separate middle"
    >
      <span v-html="collectionObject.objectTag" />
      <div class="horizontal-right-content">
        <ul class="context-menu">
          <li>
            <CONavegation class="margin-small-right" />
          </li>
          <li v-if="otu">
            <BrowseOTU :otu="otu" />
          </li>
          <li>
            <RadialAnnotator :global-id="collectionObject.globalId" />
          </li>
          <li>
            <RadialObject :global-id="collectionObject.globalId" />
          </li>
          <li>
            <RadialFilter object-type="CollectionObject" />
          </li>
          <li>
            <VBtn
              circle
              color="submit"
              title="Edit on comprehensive task"
              @click="openComprehenseive(collectionObject.id)"
            >
              <VIcon
                x-small
                title="Edit on comprehensive task"
                name="pencil"
              />
            </VBtn>
          </li>
          <li>
            <RadialNavigator :global-id="collectionObject.globalId" />
          </li>
        </ul>
      </div>
      <RadialFilterAttribute :parameters="{ collection_object_id: [collectionObject.id] }" />
    </div>
  </NavBar>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../store/getters/getters'
import VBtn from 'components/ui/VBtn'
import VIcon from 'components/ui/VIcon'
import NavBar from 'components/layout/NavBar.vue'
import CONavegation from './CONavegation.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import RadialObject from 'components/radials/object/radial.vue'
import RadialNavigator from 'components/radials/navigation/radial.vue'
import RadialFilter from 'components/radials/filter/radial.vue'
import RadialFilterAttribute from 'components/radials/filter/RadialFilterAttribute.vue'
import BrowseOTU from 'components/otu/otu.vue'
import { RouteNames } from 'routes/routes'

const store = useStore()
const collectionObject = computed(() => store.getters[GetterNames.GetCollectionObject])
const otu = computed(() => {
  const determinations = store.getters[GetterNames.GetDeterminations]
  const d = determinations[0]

  return d && { id: d.otu_id }
})

const openComprehenseive = (id) => {
  window.open(`${RouteNames.DigitizeTask}?collection_object_id=${id}`, '_self')
}
</script>
