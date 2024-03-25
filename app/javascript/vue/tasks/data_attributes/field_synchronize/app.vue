<template>
  <h1>Field synchronize</h1>
  <div class="overflow-x-scroll">
    <VTable
      :attributes="attributes"
      :list="list"
    />
  </div>
</template>

<script setup>
import { onBeforeMount, ref } from 'vue'
import { Metadata, CollectingEvent } from '@/routes/endpoints'
import { COLLECTING_EVENT } from '@/constants'
import VTable from './components/Table/VTable.vue'

const QUERY_PARAMETER = {
  collecting_event_query: {
    model: COLLECTING_EVENT
  }
}

const attributes = ref([])
const list = ref([])

onBeforeMount(() => {
  Metadata.attributes({ model: COLLECTING_EVENT }).then(({ body }) => {
    attributes.value = body
  })

  CollectingEvent.filter({ per: 10 }).then(({ body }) => {
    list.value = body
  })
})
</script>
