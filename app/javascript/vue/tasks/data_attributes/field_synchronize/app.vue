<template>
  <h1>Field synchronize</h1>
  <div v-if="QUERY_PARAMETER[queryParam]">
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
  </div>
  <div v-else>
    <i v-if="queryParam">Query parameter is not supported</i>
    <i v-else>Query parameter is missing</i>
  </div>
</template>

<script setup>
import { onBeforeMount, ref, computed } from 'vue'
import { Metadata, CollectingEvent } from '@/routes/endpoints'
import { COLLECTING_EVENT } from '@/constants'
import { URLParamsToJSON } from '@/helpers'
import { QUERY_PARAMETER } from './constants'
import VTable from './components/Table/VTable.vue'
import PropertySelector from './components/Table/PropertySelector.vue'

defineOptions({
  name: 'FieldSynchronize'
})

const attributes = ref([])
const list = ref([])
const selectedProperties = ref([])
const queryParam = ref(null)

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

function getQueryParamFromUrl() {
  const queryParameters = Object.keys(QUERY_PARAMETER)
  const parameters = URLParamsToJSON(window.location.href)
  const queryParam = Object.keys(parameters).find((param) =>
    queryParameters.includes(param)
  )

  return queryParam
}

onBeforeMount(() => {
  queryParam.value = getQueryParamFromUrl()

  if (queryParam.value) {
    Metadata.attributes({
      model: COLLECTING_EVENT,
      mode: 'editable'
    }).then(({ body }) => {
      attributes.value = body
    })

    CollectingEvent.filter({ per: 10 }).then(({ body }) => {
      list.value = body
    })
  }
})
</script>
