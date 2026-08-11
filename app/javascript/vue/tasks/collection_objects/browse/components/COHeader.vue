<template>
  <NavBar navbar-class="panel content rounded-tl-none rounded-tr-none">
    <div
      v-if="collectionObject.id"
      class="flex-separate middle"
    >
      <div class="horizontal-left-content middle gap-small">
        <AutocompletePopover
          url="/collection_objects/autocomplete"
          title="Search a collection object to browse"
          placeholder="Search a collection object"
          param="term"
          medium
          label="label_html"
          autofocus
          clear-after
          @select="(item) => emit('select', item)"
        />
        <span v-html="collectionObject.objectTag" />
        <DwcReindexWarning />
      </div>
      <div class="horizontal-right-content">
        <ul class="context-menu">
          <li>
            <CONavegation class="margin-small-right" />
          </li>
          <li v-if="otu">
            <BrowseOTU :otu="otu" />
          </li>
          <li>
            <VBtn
              icon
              variant="tonal"
              color="primary"
              title="Edit on comprehensive task"
              @click="openComprehenseive(collectionObject.id)"
            >
              <IconPencil class="w-4 h-4" />
            </VBtn>
          </li>
          <li>
            <RadialAnnotator
              :global-id="collectionObject.globalId"
              @create="handleRadialCreate"
              @delete="handleRadialDelete"
              @update="handleRadialUpdate"
            />
          </li>
          <li>
            <RadialObject :global-id="collectionObject.globalId" />
          </li>

          <li>
            <RadialNavigator :global-id="collectionObject.globalId" />
          </li>
        </ul>
      </div>
      <RadialFilterAttribute
        :parameters="{ collection_object_id: [collectionObject.id] }"
      />
    </div>
  </NavBar>
</template>

<script setup>
import { addToArray, removeFromArray } from '@/helpers'
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'
import { DEPICTION, IDENTIFIER, COLLECTION_OBJECT } from '@/constants'
import { RouteNames } from '@/routes/routes'
import VBtn from '@/components/ui/VBtn'
import IconPencil from '@/components/Icon/IconPencil.vue'
import NavBar from '@/components/layout/NavBar.vue'
import CONavegation from './CONavegation.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import RadialFilterAttribute from '@/components/radials/linker/RadialFilterAttribute.vue'
import BrowseOTU from '@/components/otu/otu.vue'
import DwcReindexWarning from './DwcReindexWarning.vue'
import AutocompletePopover from '@/components/ui/Autocomplete/AutocompletePopover.vue'

const emit = defineEmits(['select'])

const store = useStore()
const collectionObject = computed(
  () => store.getters[GetterNames.GetCollectionObject]
)
const otu = computed(() => {
  const determinations = store.getters[GetterNames.GetDeterminations]
  const d = determinations[0]

  return d && { id: d.otu_id }
})

const openComprehenseive = (id) => {
  window.open(`${RouteNames.DigitizeTask}?collection_object_id=${id}`, '_self')
}

function handleRadialCreate({ item }) {
  switch (item.base_class) {
    case DEPICTION:
      addToArray(store.state.depictions.list, item)
      break

    case IDENTIFIER:
      store.commit(MutationNames.AddIdentifier, {
        objectType: COLLECTION_OBJECT,
        item
      })
      break
  }
}

function handleRadialDelete({ item }) {
  switch (item.base_class) {
    case DEPICTION:
      removeFromArray(store.state.depictions.list, item)
      break
    case IDENTIFIER:
      removeFromArray(store.state.identifiers[COLLECTION_OBJECT], item)
      break
  }
}

function handleRadialUpdate({ item }) {
  switch (item.base_class) {
    case DEPICTION:
      addToArray(store.state.depictions.list, item)
      break
  }
}
</script>
