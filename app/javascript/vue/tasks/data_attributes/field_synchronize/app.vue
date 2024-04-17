<template>
  <h1>Field synchronize</h1>
  <VSpinner
    v-if="isLoading"
    full-screen
  />
  <VSpinner
    v-if="isUpdating"
    full-screen
    legend="Saving..."
  />
  <div
    v-if="QUERY_PARAMETER[queryParam]"
    class="horizontal-left-content align-start gap-medium"
  >
    <div class="flex-col gap-medium left-column">
      <FieldForm
        :predicates="predicates"
        :attributes="attributes"
        v-model:selected-predicates="selectedPredicates"
        v-model:selected-attributes="selectedAttributes"
      />
      <RegexForm
        :attributes="selectedAttributes"
        :predicates="selectedPredicates"
        v-model="regexPatterns"
        v-model:to="to"
        v-model:from="from"
      />
    </div>
    <div class="overflow-x-scroll">
      <VTable
        :attributes="selectedAttributes"
        :list="tableList"
        :predicates="selectedPredicates"
        :preview-header="previewHeader"
        :model="currentModel"
        @remove:attribute="
          (attr) =>
            removeFromArray(selectedAttributes, attr, { primitive: true })
        "
        @remove:predicate="(item) => removeFromArray(selectedPredicates, item)"
        @update:attribute="saveFieldAttribute"
        @update:attribute-column="saveColumnAttribute"
        @update:predicate-column="saveColumnPredicate"
        @update:data-attribute="saveDataAttribute"
        @update:preview="processPreview"
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
import { Metadata, DataAttribute } from '@/routes/endpoints'
import { DATA_ATTRIBUTE_INTERNAL_ATTRIBUTE } from '@/constants'
import {
  URLParamsToJSON,
  ajaxCall,
  randomUUID,
  removeFromArray
} from '@/helpers'
import { QUERY_PARAMETER } from './constants'
import VTable from './components/Table/VTable.vue'
import RegexForm from './components/Regex/RegexForm.vue'
import FieldForm from './components/Field/FieldForm.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

defineOptions({
  name: 'FieldSynchronize'
})

const attributes = ref([])
const list = ref([])
const selectedAttributes = ref([])
const selectedPredicates = ref([])
const queryParam = ref(null)
const queryValue = ref(undefined)
const predicates = ref([])
const dataAttributes = ref([])
const currentModel = computed(() => QUERY_PARAMETER[queryParam.value]?.model)
const from = ref()
const to = ref()
const regexPatterns = ref([])
const currentPage = ref()
const isLoading = ref(false)
const isUpdating = ref(false)

function applyRegex(text, regexPatterns) {
  try {
    for (let i = 0; i < regexPatterns.length; i++) {
      const pattern = regexPatterns[i]
      const regex = new RegExp(pattern.match, 'g')

      if (pattern.match) {
        if (pattern.replace) {
          text = text?.replace(regex, pattern.value)
        } else {
          const found = text.match(regex)

          if (found) {
            text = found[0]
          } else {
            return text
          }
        }
      }
    }

    return text
  } catch {
    return text
  }
}

const previewHeader = computed(() => {
  const _from = from.value?.name || from.value
  const _to = to.value?.name || to.value

  return _from && _to ? `${_from}→${_to}` : ''
})

const tableList = computed(() => {
  return list.value.map((item) => {
    const data = {
      ...item
    }

    if (from.value && to.value) {
      try {
        const items = from.value?.id
          ? item.dataAttributes[from.value.id].map((item) => item.value)
          : item.attributes[from.value]

        data.preview = [items].flat().map((value) => {
          const newValue =
            value && regexPatterns.value.length
              ? applyRegex(value, regexPatterns.value)
              : value

          return {
            value: newValue,
            hasChanged: newValue !== value
          }
        })
      } catch (e) {}
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

function processPreview(items) {
  const predicateId = to.value?.id

  const promises = items.map(({ item, index, value }) => {
    if (predicateId) {
      const dataAttribute = item.dataAttributes[predicateId][index]

      return saveDataAttribute({
        ...dataAttribute,
        objectId: item.id,
        value
      })
    }

    return saveFieldAttribute({ item, attribute: to.value, value })
  })

  makeNotificationWhenPromisesEnd(promises).then((res) => {
    isUpdating.value = false
  })
}

function makeNotificationWhenPromisesEnd(promises) {
  const handlePromises = Promise.allSettled(promises)

  handlePromises.then((res) => {
    const resolvedCount = res.filter((r) => r.status === 'fulfilled').length
    const rejectedCount = (promises.length = resolvedCount)

    const message = rejectedCount.length
      ? `${resolvedCount} record(s) were successfully saved. ${rejectedCount} were not saved`
      : `${resolvedCount} record(s) were successfully saved`

    TW.workbench.alert.create(message)
  })

  return handlePromises
}

function saveColumnAttribute(items) {
  const requests = items.map((item) => saveFieldAttribute(item))

  isUpdating.value = true
  makeNotificationWhenPromisesEnd(requests).then((res) => {
    isUpdating.value = false
  })
}

function saveColumnPredicate(items) {
  const requests = items.map((item) => saveDataAttribute(item))

  isUpdating.value = true
  makeNotificationWhenPromisesEnd(requests).then((res) => {
    isUpdating.value = false
  })
}

function saveFieldAttribute({ item, attribute, value }) {
  const { service } = QUERY_PARAMETER[queryParam.value]
  const objectParam = queryParam.value.slice(0, -6)

  const request = service.update(item.id, {
    [objectParam]: {
      [attribute]: value
    }
  })

  request
    .then((_) => {
      const currentItem = list.value.find((obj) => obj.id === item.id)

      currentItem.attributes[attribute] = value
    })
    .catch(() => {})

  return request
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

watch(selectedAttributes, (newVal) => {
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
    const request = DataAttribute.destroy(id)

    request.then(() => {
      removeFromArray(predicates, { uuid }, { property: 'uuid' })

      if (!predicates.length) {
        predicates.push(makeDataAttribute({ predicateId }))
      }
    })

    return request
  }

  const request = id
    ? DataAttribute.update(id, payload)
    : DataAttribute.create(payload)

  request.then(({ body }) => {
    const _dataAttributes = dataAttributes.value[objectId][predicateId]
    const da = _dataAttributes.find((item) => item.uuid === uuid)
    const currentDa = predicates.find((item) => item.uuid === uuid)

    da.id = body.id
    da.value = body.value
    currentDa.value = body.id
    currentDa.value = body.value

    TW.workbench.alert.create('Data attribute was successfully saved')
  })

  return request
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

  isLoading.value = true

  ajaxCall('get', '/tasks/data_attributes/field_synchronize/values', {
    params
  })
    .then(({ body }) => {
      list.value = body.map((item) => {
        const { id, ...attributes } = item

        if (!dataAttributes.value[id]) {
          dataAttributes.value[id] = fillDataAttributes({})
        }

        return {
          id,
          uuid: randomUUID(),
          attributes,
          dataAttributes: dataAttributes.value[id]
        }
      })
    })
    .finally(() => {
      isLoading.value = false
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

<style scoped>
.left-column {
  width: 400px;
}
</style>
