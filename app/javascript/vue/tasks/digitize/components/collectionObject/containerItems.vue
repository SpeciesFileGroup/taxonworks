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
    <TableCollectionObjects />
  </div>
</template>

<script setup>
import { GetterNames } from '../../store/getters/getters'
import { ActionNames } from '../../store/actions/actions'
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import TableCollectionObjects from '../collectionObject/tableCollectionObjects'
import useHotkey from 'vue3-hotkey'
import platformKey from '@/helpers/getPlatformKey.js'

const store = useStore()

const collectionObject = computed(
  () => store.getters[GetterNames.GetCollectionObject]
)
const collectionObjects = computed(
  () => store.getters[GetterNames.GetCollectionObjects]
)

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
  store.dispatch(ActionNames.ResetTaxonDetermination)
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
