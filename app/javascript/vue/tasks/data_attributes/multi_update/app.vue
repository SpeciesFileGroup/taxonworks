<template>
  <h1>Multi update</h1>
  <div class="horizontal-left-content align-start gap-medium">
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

const store = useStore()
const { queryParam, queryValue } = useQueryParam()

onBeforeMount(() => {
  if (queryParam.value) {
    console.log(queryParam.value)
    store.loadObjects({
      queryParam: queryParam.value,
      queryValue: queryValue.value
    })
  }
})
</script>
