<template>
  <h1>Multi update</h1>
  <div class="horizontal-left-content align-start gap-medium">
    <VSpinner
      v-if="store.isLoading"
      full-screen
    />
    <VSpinner
      v-if="store.isSaving"
      full-screen
      :legend="`Saving... please wait. ${store.save.current} of ${store.save.total}.`"
    />
    <PredicateSelector />
    <DataAttributeTable />
  </div>
</template>

<script setup>
import { onBeforeMount } from 'vue'
import { useQueryParam } from '../field_synchronize/composables'
import PredicateSelector from './components/PredicateSelector.vue'
import useStore from './store/store'
import DataAttributeTable from './components/DataAttributeTable.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

defineOptions({
  name: 'MultiUpdate'
})

const store = useStore()
const { queryParam, queryValue } = useQueryParam()

onBeforeMount(() => {
  if (queryParam.value) {
    store.loadObjects({
      queryParam: queryParam.value,
      queryValue: queryValue.value
    })
  }
})
</script>
