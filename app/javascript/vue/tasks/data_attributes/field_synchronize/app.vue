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
import { onBeforeMount, ref, computed, watch } from 'vue'
import { Metadata, CollectingEvent, DataAttribute } from '@/routes/endpoints'
import { COLLECTING_EVENT } from '@/constants'
import { URLParamsToJSON, ajaxCall } from '@/helpers'
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
const queryValue = ref(undefined)
const predicates = ref([])

const currentModel = computed(() => QUERY_PARAMETER[queryParam.value]?.model)

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

  return {
    queryParam,
    queryValue: parameters[queryParam]
  }
}

watch(selectedProperties, (newVal) => {
  if (newVal.length) {
    loadAttributes(newVal)
  }
})

function loadAttributes(attribute) {
  const payload = {
    [queryParam.value]: queryValue.value
  }

  ajaxCall('get', '/tasks/data_attributes/field_synchronize/values', {
    params: { [queryParam.value]: queryValue.value, attribute }
  }).then(({ body }) => {
    list.value = body
  })

  DataAttribute.brief(payload).then(({ body }) => {
    predicates.value = body
  })
}

onBeforeMount(() => {
  const data = getQueryParamFromUrl()

  queryParam.value = data.queryParam
  queryValue.value = data.queryValue

  if (currentModel.value) {
    Metadata.attributes({
      model: currentModel.value,
      mode: 'editable'
    }).then(({ body }) => {
      attributes.value = body
    })
  }
})
</script>
