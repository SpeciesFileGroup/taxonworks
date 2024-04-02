<template>
  <h1>Field synchronize</h1>
  <div v-if="QUERY_PARAMETER[queryParam]">
    <PropertySelector
      :properties="attributes"
      v-model="selectedProperties"
    />
    <PredicateSelector
      :predicates="predicates"
      v-model="selectedPredicates"
    />
    <RegexForm
      :attributes="selectedProperties"
      v-model="regexPattern"
      v-model:to="to"
      v-model:from="from"
    />
    <div class="overflow-x-scroll">
      <VTable
        :attributes="selectedProperties"
        :list="tableList"
        :predicates="selectedPredicates"
        :preview-header="previewHeader"
        @remove:attribute="
          (attr) => {
            selectedProperties = selectedProperties.filter(
              (item) => item !== attr
            )
          }
        "
        @update:attribute="updateField"
        @update:data-attribute="saveDataAttribute"
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
import { DATA_ATTRIBUTE_INTERNAL_ATTRIBUTE } from '@/constants'
import {
  URLParamsToJSON,
  ajaxCall,
  randomUUID,
  removeFromArray
} from '@/helpers'
import { QUERY_PARAMETER } from './constants'
import VTable from './components/Table/VTable.vue'
import PropertySelector from './components/PropertySelector.vue'
import PredicateSelector from './components/PredicateSelector.vue'
import RegexForm from './components/RegexForm.vue'

defineOptions({
  name: 'FieldSynchronize'
})

const attributes = ref([])
const list = ref([])
const selectedProperties = ref([])
const selectedPredicates = ref([])
const queryParam = ref(null)
const queryValue = ref(undefined)
const predicates = ref([])
const dataAttributes = ref([])
const currentModel = computed(() => QUERY_PARAMETER[queryParam.value]?.model)
const from = ref()
const to = ref()
const regexPattern = ref('')

function applyRegex(text, regexPattern) {
  const regex = new RegExp(regexPattern, 'g')

  return text?.replace(regex, '')
}

const previewHeader = computed(() => {
  return from.value && to.value ? `${from.value}→${to.value}` : ''
})

const tableList = computed(() => {
  return list.value.map((item) => {
    const data = {
      ...item
    }

    if (from.value && to.value && regexPattern.value) {
      try {
        data.preview = applyRegex(
          item.attributes[from.value],
          regexPattern.value
        )
      } catch (e) {
        console.log(e)
      }
    }

    return data
  })
})

function makeDataAttribute({ predicateId, value = null, id = null }) {
  return {
    id,
    uuid: randomUUID(),
    predicateId,
    value
  }
}

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

function saveDataAttribute({ id, value, objectId, predicateId, uuid }) {
  const objectItem = list.value.find((item) => item.id === objectId)
  const predicates = objectItem.dataAttributes[predicateId]
  const payload = {
    data_attribute: {
      controlled_vocabulary_term_id: predicateId,
      attribute_subject_id: objectId,
      attribute_subject_type: currentModel.value,
      type: DATA_ATTRIBUTE_INTERNAL_ATTRIBUTE,
      value
    }
  }

  if (!value) {
    DataAttribute.destroy(id).then(() => {
      removeFromArray(predicates, { uuid }, 'uuid')

      if (!predicates.length) {
        predicates.push(makeDataAttribute({ predicateId }))
      }
      TW.workbench.alert.create('Data attribute was successfully removed')
    })
  } else {
    const request = id
      ? DataAttribute.update(id, payload)
      : DataAttribute.create(payload)

    request.then(({ body }) => {
      const da = predicates.find((item) => item.uuid === uuid)

      da.id = body.id
      da.value = body.value
      TW.workbench.alert.create('Data attribute was successfully updated')
    })
  }
}

function loadPredicates(params) {
  DataAttribute.brief({
    ...params,
    type: DATA_ATTRIBUTE_INTERNAL_ATTRIBUTE
  }).then(async ({ body }) => {
    predicates.value = body.index.map((item) => {
      const [id] = Object.keys(item)
      const [name] = Object.values(item)

      return {
        id: Number(id),
        name
      }
    })

    dataAttributes.value = makeDataAttributeList(body)
  })
}

function loadAttributes(attribute) {
  const params = {
    [queryParam.value]: queryValue.value,
    attribute
  }

  ajaxCall('get', '/tasks/data_attributes/field_synchronize/values', {
    params
  }).then(({ body }) => {
    list.value = body.map((item) => {
      const { id, ...attributes } = item

      return {
        id,
        attributes,
        dataAttributes: dataAttributes.value[id] || fillDataAttributes({})
      }
    })
  })
}

function fillDataAttributes(obj) {
  predicates.value.forEach(({ id }) => {
    if (!obj[id]) {
      obj[id] = [makeDataAttribute({ predicateId: id })]
    }
  })

  return obj
}

function makeDataAttributeList({ data, index }) {
  const obj = {}

  data.forEach(([id, objectId, predicateId, value]) => {
    const dataAttribute = makeDataAttribute({
      id,
      predicateId,
      value,
      objectId
    })
    const dataAttributes = obj[objectId]

    if (dataAttributes) {
      const arr = dataAttributes[predicateId]

      if (arr) {
        arr.push(dataAttribute)
      } else {
        dataAttributes[predicateId] = [dataAttribute]
      }
    } else {
      obj[objectId] = {
        [predicateId]: [dataAttribute]
      }
    }
  })

  for (const key in obj) {
    fillDataAttributes(obj[key])
  }

  return obj
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

    loadPredicates({ [queryParam.value]: queryValue.value })
  }
})
</script>
