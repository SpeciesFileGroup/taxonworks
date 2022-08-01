<template>
  <h3>Catalog number namespace mapping</h3>
  <VSwitch
    v-model="tabSelected"
    :options="Object.values(TABS)"
  />
  <CatalogNumberTable v-if="tabSelected === TABS.primaryMapping" />
  <CatalogNumberDefaultTable v-if="tabSelected === TABS.collectionCode" />
</template>

<script setup>

import { useStore } from 'vuex'
import { computed, ref, onUnmounted } from 'vue'
import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'
import { ActionNames } from '../../../store/actions/actions'
import CatalogNumberTable from './CatalogNumberTable.vue'
import VSwitch from 'components/switch.vue'
import CatalogNumberDefaultTable from './CatalogNumberDefaultTable.vue'

const TABS = {
  primaryMapping: 'Primary mapping',
  collectionCode: 'CollectionCode only'
}

const store = useStore()
const dataset = computed(() => store.getters[GetterNames.GetDataset])
const tabSelected = ref(TABS.primaryMapping)

const settings = computed({
  get: () => store.getters[GetterNames.GetSettings],

  set: value => store.commit(MutationNames.SetSettings, value)
})

const reloadDataset = () => {
  store.dispatch(ActionNames.LoadDataset, dataset.value.id)
  store.dispatch(ActionNames.LoadDatasetRecords)
}

onUnmounted(() => {
  if (settings.value.namespaceUpdated) {
    reloadDataset()
    settings.value.namespaceUpdated = false
  }
})

</script>
