<template>
  <div>
    <h2 class="flex-separate">
      {{
        collectionObjects.length > 1 ? 'Container details' : 'Object details'
      }}
      <div>
        <VBtn
          :disabled="!collectionObjects.length || isAdding"
          medium
          color="create"
          @click="addToContainer"
        >
          Add to container
        </VBtn>
      </div>
    </h2>

    <div
      v-if="container"
      class="horizontal-left-content middle gap-small margin-medium-bottom"
    >
      <span v-html="container.object_tag" />
      <RadialAnnotator
        :global-id="container.global_id"
        reload
      />
      <RadialNavigator :global-id="container.global_id" />
    </div>

    <TableCollectionObjects />
  </div>
</template>

<script setup>
import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { useHotkey } from '@/composables'
import { useTaxonDeterminationStore } from '../../store/pinia'
import TableCollectionObjects from '../collectionObject/tableCollectionObjects'
import platformKey from '@/helpers/getPlatformKey.js'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import useBiocurationStore from '@/tasks/field_occurrences/new/store/biocurations.js'
import useBiologicalAssociationStore from '@/components/Form/FormBiologicalAssociation/store/biologicalAssociations.js'

const store = useStore()
const determinationStore = useTaxonDeterminationStore()
const biologicalAssociationStore = useBiologicalAssociationStore()
const biocurationStore = useBiocurationStore()
const isAdding = ref(false)

const collectionObject = computed(
  () => store.getters[GetterNames.GetCollectionObject]
)
const collectionObjects = computed(
  () => store.getters[GetterNames.GetCollectionObjects]
)
const locked = computed(() => store.getters[GetterNames.GetLocked])

const container = computed(() => store.getters[GetterNames.GetContainer])

const shortcuts = ref([
  {
    keys: [platformKey(), 'p'],
    handler() {
      if (!isAdding.value) {
        addToContainer()
      }
    }
  }
])

useHotkey(shortcuts.value)

function newDigitalization() {
  store.dispatch(ActionNames.NewCollectionObject)
  determinationStore.reset({ keepRecords: locked.value.taxonDeterminations })
  biocurationStore.reset({ keepRecords: locked.value.biocuration })
  biologicalAssociationStore.reset({
    keepRecords: locked.value.biologicalAssociations
  })
}

async function addToContainer() {
  if (!collectionObjects.value.length || isAdding.value) return
  isAdding.value = true
  await store.dispatch(ActionNames.SaveDigitalization)
  await store.dispatch(ActionNames.AddToContainer, collectionObject.value)
  newDigitalization()
  await store.dispatch(ActionNames.SaveDigitalization)
  await store.dispatch(ActionNames.AddToContainer, collectionObject.value)
  isAdding.value = false
}
</script>
