<template>
  <h1>Field synchronize</h1>
  <PropertySelector
    :properties="attributes"
    v-model="selectedProperties"
  />
  <div class="overflow-x-scroll">
    <VTable
      :attributes="selectedProperties"
      :list="tableList"
      @remove:attribute="
        (attr) => {
          selectedProperties = selectedProperties.filter(
            (item) => item !== attr
          )
        }
      "
      @update:attribute="updateField"
    />
  </div>
</template>

<script setup>
import { onBeforeMount, ref, computed } from 'vue'
import { Metadata, CollectingEvent } from '@/routes/endpoints'
import { COLLECTING_EVENT } from '@/constants'
import VTable from './components/Table/VTable.vue'
import PropertySelector from './components/Table/PropertySelector.vue'

const QUERY_PARAMETER = {
  collecting_event_query: {
    model: COLLECTING_EVENT
  }
}

defineOptions({
  name: 'FieldSynchronize'
})

const attributes = ref([])
const list = ref([])
const selectedProperties = ref([])

const tableList = computed(() =>
  list.value.map((item) => {
    const data = {
      id: item.id
    }

    attributes.value.forEach((attr) => {
      data[attr] = item[attr]
    })

    return data
  })
)

function updateField({ item, attribute, value }) {
  CollectingEvent.update(item.id, {
    collecting_event: {
      [attribute]: value
    }
  }).then((body) => {
    const currentItem = list.value.find((obj) => obj.id === item.id)

    currentItem[attribute] = value
    TW.workbench.alert.create('Field was successfully updated')
  })
}

onBeforeMount(() => {
  Metadata.attributes({ model: COLLECTING_EVENT }).then(({ body }) => {
    attributes.value = body
  })

  CollectingEvent.filter({ per: 10 }).then(({ body }) => {
    list.value = body
  })
})
</script>
