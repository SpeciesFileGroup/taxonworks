<template>
  <h1>Field synchronize</h1>
  <PropertySelector
    :properties="attributes"
    v-model="selectedProperties"
  />
  <div class="overflow-x-scroll">
    <VTable
      :attributes="selectedProperties"
      :list="list"
      @remove:attribute="
        (attr) => {
          selectedProperties = selectedProperties.filter(
            (item) => item !== attr
          )
        }
      "
    />
  </div>
</template>

<script setup>
import { onBeforeMount, ref } from 'vue'
import { Metadata, CollectingEvent } from '@/routes/endpoints'
import { COLLECTING_EVENT } from '@/constants'
import VTable from './components/Table/VTable.vue'
import PropertySelector from './components/Table/PropertySelector.vue'

const QUERY_PARAMETER = {
  collecting_event_query: {
    model: COLLECTING_EVENT
  }
}

const attributes = ref([])
const list = ref([])
const selectedProperties = ref([])

onBeforeMount(() => {
  Metadata.attributes({ model: COLLECTING_EVENT }).then(({ body }) => {
    attributes.value = body
  })

  CollectingEvent.filter({ per: 10 }).then(({ body }) => {
    list.value = body
  })
})
</script>
