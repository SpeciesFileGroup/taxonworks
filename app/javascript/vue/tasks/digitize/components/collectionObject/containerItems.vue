<template>
  <div>
    <h2 class="flex-separate">
      {{
        collectionObjects.length > 1 ? 'Container details' : 'Object details'
      }}
      <div>
        <button
          :disabled="!collectionObjects.length"
          type="button"
          @click="addToContainer"
          class="button normal-input button-default"
        >
          Add to container
        </button>
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

const store = useStore()
const determinationStore = useTaxonDeterminationStore()

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
      addToContainer()
    }
  }
])

useHotkey(shortcuts.value)

function newDigitalization() {
  store.dispatch(ActionNames.NewCollectionObject)
  store.dispatch(ActionNames.NewIdentifier)
  console.log(locked.value.taxonDeterminations)
  determinationStore.reset({ keepRecords: locked.value.taxonDeterminations })
}

function addToContainer() {
  if (!collectionObjects.value.length) return
  store.dispatch(ActionNames.SaveDigitalization).then(() => {
    store
      .dispatch(ActionNames.AddToContainer, collectionObject.value)
      .then(() => {
        newDigitalization()
        store.dispatch(ActionNames.SaveDigitalization).then(() => {
          store.dispatch(ActionNames.AddToContainer, collectionObject.value)
        })
      })
  })
}
</script>
